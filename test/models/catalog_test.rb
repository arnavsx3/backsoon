require "test_helper"

class CatalogTest < ActiveSupport::TestCase
  test "names are normalized and blank names are rejected" do
    item = users(:one).items.new(name: "  Notebook  ")
    assert item.valid?
    assert_equal "Notebook", item.name
    item.name = "  "
    refute item.valid?
    refute users(:one).borrowers.new(name: " ").valid?
  end

  test "borrower email is optional and normalized when supplied" do
    borrower = users(:one).borrowers.new(name: "Sam", email: " SAM@EXAMPLE.COM ")
    assert borrower.valid?
    assert_equal "sam@example.com", borrower.email
    borrower.email = ""
    assert borrower.valid?
    borrower.email = "invalid"
    refute borrower.valid?
  end

  test "items and people with history cannot be deleted" do
    refute items(:charger).destroy
    refute borrowers(:friend).destroy
    assert loans(:returned).reload
  end

  test "available items exclude items currently lent out" do
    assert_includes users(:one).items.available, items(:charger)
    refute_includes users(:one).items.available, items(:book)
  end
end
