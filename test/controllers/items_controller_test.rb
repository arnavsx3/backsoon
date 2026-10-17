require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "catalog and history show only this user's records" do
    get items_path
    assert_response :success
    assert_select "h2", "The Creative Act"
    assert_no_match "Private camera", response.body
    get item_path(items(:book))
    assert_response :success
    assert_select "h3", "Mira"
  end

  test "creation and editing ignore an injected owner" do
    assert_difference "users(:one).items.count" do
      post items_path, params: { item: { name: "Drill", description: "Blue case", user_id: users(:two).id } }
    end
    item = users(:one).items.find_by!(name: "Drill")
    assert_redirected_to item_path(item)
    patch item_path(item), params: { item: { name: "Cordless drill", user_id: users(:two).id } }
    assert_equal "Cordless drill", item.reload.name
    assert_equal users(:one), item.user
    get edit_item_path(item)
    assert_response :success
  end

  test "invalid forms return useful errors" do
    assert_no_difference "Item.count" do
      post items_path, params: { item: { name: " " } }
    end
    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Name/
  end

  test "another user's records cannot be read changed or deleted" do
    get item_path(items(:other))
    assert_response :not_found
    get edit_item_path(items(:other))
    assert_response :not_found
    patch item_path(items(:other)), params: { item: { name: "Stolen" } }
    assert_response :not_found
    assert_no_difference "Item.count" do
      delete item_path(items(:other))
    end
    assert_response :not_found
  end

  test "items without history can be deleted but history remains protected" do
    item = users(:one).items.create!(name: "Unused")
    assert_difference "Item.count", -1 do
      delete item_path(item)
    end
    assert_redirected_to items_path
    assert_no_difference "Item.count" do
      delete item_path(items(:charger))
    end
    assert_redirected_to item_path(items(:charger))
    follow_redirect!
    assert_select "[role=alert]", /lending history/
  end

  test "pagination is bounded and navigable" do
    21.times { |i| users(:one).items.create!(name: "Item #{i}") }
    get items_path, params: { page: -10 }
    assert_response :success
    assert_select "nav[aria-label=Pagination]", /Page 1 of 2/
    get items_path, params: { page: 999_999 }
    assert_response :success
    assert_select "nav[aria-label=Pagination]", /Page 2 of 2/
  end
end
