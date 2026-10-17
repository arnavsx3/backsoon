require "test_helper"

class HealthTest < ActionDispatch::IntegrationTest
  test "health endpoint is available" do
    get "/up"
    assert_response :success
  end
end
