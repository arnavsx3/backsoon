require "test_helper"
require "selenium/webdriver"

ENV["SE_BROWSER_PATH"] = ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?
Capybara.default_max_wait_time = 5

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1000 ]

  private
    def sign_in(email: users(:one).email_address, password: "password")
      visit new_session_path
      fill_in "Email address", with: email
      fill_in "Password", with: password, exact: true
      click_button "Sign in", exact: true
      assert_selector "h1", text: "Out in the world."
    end
end
