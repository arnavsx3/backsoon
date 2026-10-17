require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "sign up establishes a session and normalizes the address" do
    assert_difference [ "User.count", "Session.count" ] do
      post registration_path, params: { user: { email_address: " Fresh@Example.com ", password: "twelve-characters", password_confirmation: "twelve-characters" } }
    end
    assert_redirected_to root_path
    assert cookies[:session_id]
    assert_equal "fresh@example.com", User.last.email_address
    follow_redirect!
    assert_response :success
  end

  test "invalid registrations do not create an account" do
    assert_no_difference "User.count" do
      post registration_path, params: { user: { email_address: "bad", password: "short", password_confirmation: "different" } }
    end
    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Email address/
  end

  test "duplicate addresses are rejected" do
    assert_no_difference "User.count" do
      post registration_path, params: { user: { email_address: users(:one).email_address.upcase, password: "twelve-characters", password_confirmation: "twelve-characters" } }
    end
    assert_response :unprocessable_entity
  end

  test "anonymous visitors are directed to sign in" do
    get root_path
    assert_redirected_to new_session_path
  end
end
