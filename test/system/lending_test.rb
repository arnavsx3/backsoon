require "application_system_test_case"

class LendingTest < ApplicationSystemTestCase
  test "a new account completes a lending cycle and keeps its records after signing in again" do
    visit new_registration_path
    fill_in "Email address", with: "system-new@example.com"
    fill_in "Password", with: "a-long-system-password", exact: true
    fill_in "Confirm password", with: "a-long-system-password"
    click_button "Create account"
    assert_text "Your first little handoff."

    click_link "Your things", exact: true
    click_link "+ Add an item"
    fill_in "Item name", with: "Weekend camera"
    fill_in "Description (optional)", with: "The green strap."
    click_button "Add item"
    assert_selector "h1", text: "Weekend camera"

    click_link "People", exact: true
    click_link "+ Add a person"
    fill_in "Name", with: "Sam"
    fill_in "Email (optional)", with: "sam@example.com"
    click_button "Add person"
    assert_selector "h1", text: "Sam"

    click_link "Loans", exact: true
    click_link "+ Record a loan"
    select "Weekend camera", from: "What are you lending?"
    select "Sam", from: "Who is borrowing it?"
    fill_in "Lent on", with: (Date.current - 4)
    fill_in "Expected back", with: (Date.current - 1)
    fill_in "A note for later (optional)", with: "For the weekend trip."
    click_button "Record loan"
    assert_selector "h1", text: "Weekend camera"
    assert_text "Overdue"
    assert_text "For the weekend trip."

    click_link "Loans", exact: true
    click_link "Overdue", exact: true
    assert_selector "[data-testid=loan-row]", count: 1
    fill_in "Search loans", with: "Sam"
    click_button "Search", exact: true
    assert_selector "[data-testid=loan-row]", count: 1
    click_link "Weekend camera", exact: false
    accept_confirm { click_button "Mark returned" }
    assert_text "Back where it belongs."
    assert_selector "dt", text: /back home on/i

    click_link "Your things", exact: true
    assert_text "Available"
    click_button "Sign out"
    sign_in email: "system-new@example.com", password: "a-long-system-password"
    click_link "Returned", exact: true
    assert_selector "[data-testid=loan-row]", count: 1
    assert_text "Weekend camera"
  end

  test "editing shows server validation and keeps saved changes" do
    sign_in
    visit edit_item_path(items(:charger))
    fill_in "Description (optional)", with: "The 65W one."
    click_button "Save changes"
    assert_text "The 65W one."
    visit edit_loan_path(loans(:outstanding))
    fill_in "Expected back", with: (Date.current - 10)
    click_button "Save changes"
    assert_selector "[role=alert]", text: "Due on must be on or after the lending date"
  end

  test "new loans guide users when all their things are already lent" do
    sign_in
    users(:one).loans.create!(item: items(:charger), borrower: borrowers(:friend), lent_on: Date.current, due_on: Date.current + 1)
    visit new_loan_path
    assert_text "Let’s get the basics in."
    assert_link "Add an item"
    assert_no_selector "input[type=submit][value='Record loan']"
  end

  test "mobile screens fit and long names do not overflow" do
    page.current_window.resize_to(375, 812)
    visit new_session_path
    assert_no_horizontal_overflow
    page.save_screenshot(Rails.root.join("tmp/screenshots/sign-in-mobile.png"))
    sign_in
    assert_no_horizontal_overflow
    page.save_screenshot(Rails.root.join("tmp/screenshots/dashboard-mobile.png"))
    item = users(:one).items.create!(name: "A" * 80, description: "B" * 300)
    visit item_path(item)
    assert_selector "h1", text: "A" * 80
    assert_no_horizontal_overflow
    page.current_window.resize_to(1400, 1000)
  end

  test "desktop dashboard and catalog are ready to use" do
    sign_in
    assert_no_horizontal_overflow
    page.save_screenshot(Rails.root.join("tmp/screenshots/dashboard-desktop.png"))
    click_link "Your things", exact: true
    assert_link "The Creative Act", exact: false
    assert_no_horizontal_overflow
  end

  private
    def assert_no_horizontal_overflow
      assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth"), "Page has horizontal overflow"
    end
end
