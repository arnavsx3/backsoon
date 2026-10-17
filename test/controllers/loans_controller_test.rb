require "test_helper"

class LoansControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "dashboard defaults to outstanding and all filters work" do
    get root_path
    assert_response :success
    assert_select "[data-testid=loan-row]", count: 1
    assert_no_match "Private camera", response.body
    get loans_path, params: { status: "returned" }
    assert_select "[data-testid=loan-row]", count: 1
    assert_match "USB-C charger", response.body
    get loans_path, params: { status: "all" }
    assert_select "[data-testid=loan-row]", count: 2
    loans(:outstanding).update!(due_on: Date.current - 1)
    get loans_path, params: { status: "overdue" }
    assert_select "[data-testid=loan-row]", count: 1
    get loans_path, params: { status: "not-a-status" }
    assert_response :success
  end

  test "search combines with filters and safely renders input" do
    get loans_path, params: { status: "all", q: "charger" }
    assert_select "[data-testid=loan-row]", count: 1
    get loans_path, params: { status: "returned", q: "Creative" }
    assert_select "[data-testid=loan-row]", count: 0
    get loans_path, params: { q: "<script>alert(1)</script>" }
    assert_response :success
    assert_no_match "<script>alert(1)</script>", response.body
  end

  test "new forms use only owned available items and people" do
    get new_loan_path
    assert_response :success
    assert_select "option", text: "USB-C charger"
    assert_select "option", text: "Private camera", count: 0
    assert_select "option", text: "Private person", count: 0
    get new_loan_path(item_id: items(:other).id)
    assert_response :not_found
  end

  test "recording a loan ignores forged ownership and returned status" do
    assert_difference "users(:one).loans.count" do
      post loans_path, params: { loan: attributes.merge(user_id: users(:two).id, returned_on: Date.current) }
    end
    loan = users(:one).loans.find_by!(item: items(:charger), returned_on: nil)
    assert_redirected_to loan_path(loan)
    assert loan.outstanding?
    assert_equal users(:one), loan.user
    get loan_path(loan)
    assert_response :success
    patch loan_path(loan), params: { loan: { notes: "Updated note", due_on: Date.current + 10 } }
    assert_equal "Updated note", loan.reload.notes
    assert_equal Date.current + 10, loan.due_on
  end

  test "validation prevents duplicate loans and malformed dates" do
    assert_no_difference "Loan.count" do
      post loans_path, params: { loan: attributes.merge(item_id: items(:book).id) }
    end
    assert_response :unprocessable_entity
    assert_select "[role=alert]", /already out on loan/
    post loans_path, params: { loan: attributes.merge(lent_on: "not-a-date") }
    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Lent on/
  end

  test "foreign references cannot be submitted" do
    assert_no_difference "Loan.count" do
      post loans_path, params: { loan: attributes.merge(item_id: items(:other).id) }
    end
    assert_response :not_found
    post loans_path, params: { loan: attributes.merge(borrower_id: borrowers(:other).id) }
    assert_response :not_found
  end

  test "loans and returns cannot be accessed across accounts" do
    get loan_path(loans(:private))
    assert_response :not_found
    get edit_loan_path(loans(:private))
    assert_response :not_found
    patch loan_path(loans(:private)), params: { loan: { notes: "Forged" } }
    assert_response :not_found
    post loan_return_path(loans(:private))
    assert_response :not_found
    assert loans(:private).reload.outstanding?
  end

  test "returning a loan records today and repeating the request preserves history" do
    post loan_return_path(loans(:outstanding))
    assert_redirected_to loan_path(loans(:outstanding))
    date = loans(:outstanding).reload.returned_on
    travel 1.day do
      post loan_return_path(loans(:outstanding))
      assert_equal date, loans(:outstanding).reload.returned_on
    end
  end

  test "signed out visitors cannot read or write lending records" do
    sign_out
    get loans_path
    assert_redirected_to new_session_path
    assert_no_difference "Loan.count" do
      post loans_path, params: { loan: attributes }
    end
    assert_redirected_to new_session_path
  end

  private
    def attributes
      { item_id: items(:charger).id, borrower_id: borrowers(:friend).id, lent_on: Date.current, due_on: Date.current + 7 }
    end
end
