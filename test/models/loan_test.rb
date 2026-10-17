require "test_helper"

class LoanTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @attributes = { item: items(:charger), borrower: borrowers(:friend), lent_on: Date.current, due_on: Date.current + 7 }
  end

  test "an item can be lent again after a return" do
    loan = @user.loans.create!(@attributes)
    loan.return!
    assert @user.loans.create!(@attributes).outstanding?
  end

  test "returning twice preserves the first return date" do
    loan = loans(:outstanding)
    loan.return!
    original = loan.returned_on
    travel 2.days do
      loan.return!
      assert_equal original, loan.reload.returned_on
    end
  end

  test "only outstanding loans before today are overdue" do
    travel_to Time.zone.local(2026, 10, 17, 12) do
      loan = @user.loans.create!(@attributes.merge(lent_on: Date.current - 2, due_on: Date.current))
      refute loan.overdue?
      loan.update!(due_on: Date.current - 1)
      assert loan.overdue?
      assert_includes @user.loans.overdue, loan
      loan.return!
      refute loan.overdue?
      refute_includes @user.loans.overdue, loan
    end
  end

  test "Ruby and SQLite both reject two outstanding loans for the same item" do
    duplicate = @user.loans.new(@attributes.merge(item: items(:book)))
    refute duplicate.valid?
    assert_includes duplicate.errors[:item_id], "is already out on loan"
    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save!(validate: false) }
  end

  test "ownership is enforced by validations and composite foreign keys" do
    foreign_item = users(:two).items.create!(name: "Another private item")
    loan = @user.loans.new(@attributes.merge(item: foreign_item))
    refute loan.valid?
    assert_includes loan.errors[:item], "must belong to your account"
    assert_raises(ActiveRecord::InvalidForeignKey) { loan.save!(validate: false) }

    loan = @user.loans.new(@attributes.merge(borrower: borrowers(:other)))
    refute loan.valid?
    assert_raises(ActiveRecord::InvalidForeignKey) { loan.save!(validate: false) }
  end

  test "dates are validated and impossible ordering is blocked by SQLite" do
    loan = @user.loans.new(@attributes.merge(lent_on: Date.current + 1))
    refute loan.valid?
    loan = @user.loans.new(@attributes.merge(due_on: Date.current - 1))
    refute loan.valid?
    assert_raises(ActiveRecord::StatementInvalid) { loan.save!(validate: false) }
    loan = @user.loans.new(@attributes.merge(returned_on: Date.current - 1))
    refute loan.valid?
    assert_raises(ActiveRecord::StatementInvalid) { loan.save!(validate: false) }
  end

  test "search matches items and borrowers and treats wildcard input literally" do
    assert_includes @user.loans.search("creative"), loans(:outstanding)
    assert_includes @user.loans.search("Mira"), loans(:returned)
    assert_empty @user.loans.search("%")
    assert_empty @user.loans.search("_")
    items(:charger).update!(name: "100% charger")
    assert_equal [ loans(:returned) ], @user.loans.search("100%").to_a
  end
end
