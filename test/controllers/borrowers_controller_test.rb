require "test_helper"

class BorrowersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "people and their history are private" do
    get borrowers_path
    assert_response :success
    assert_select "h2", "Mira"
    assert_no_match "Private person", response.body
    get borrower_path(borrowers(:friend))
    assert_response :success
    assert_match "The Creative Act", response.body
  end

  test "a person can be added and updated" do
    assert_difference "users(:one).borrowers.count" do
      post borrowers_path, params: { borrower: { name: "Sam", email: "SAM@EXAMPLE.COM", user_id: users(:two).id } }
    end
    person = users(:one).borrowers.find_by!(name: "Sam")
    assert_equal "sam@example.com", person.email
    patch borrower_path(person), params: { borrower: { notes: "Neighbor", user_id: users(:two).id } }
    assert_equal "Neighbor", person.reload.notes
    assert_equal users(:one), person.user
    get edit_borrower_path(person)
    assert_response :success
  end

  test "invalid details return errors" do
    post borrowers_path, params: { borrower: { name: "Sam", email: "wrong" } }
    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Email/
  end

  test "foreign records cannot be accessed or modified" do
    get borrower_path(borrowers(:other))
    assert_response :not_found
    patch borrower_path(borrowers(:other)), params: { borrower: { name: "Changed" } }
    assert_response :not_found
    delete borrower_path(borrowers(:other))
    assert_response :not_found
  end

  test "deletion preserves history" do
    assert_no_difference "Borrower.count" do
      delete borrower_path(borrowers(:friend))
    end
    assert_redirected_to borrower_path(borrowers(:friend))
    person = users(:one).borrowers.create!(name: "Unused")
    assert_difference "Borrower.count", -1 do
      delete borrower_path(person)
    end
  end
end
