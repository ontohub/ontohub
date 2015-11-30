Given(/^I visit the landing page with deactivated javascript$/) do
  visit root_path
end

Then(/^I should see a javascript\-deactivated\-warning$/) do
  page.should have_content("JavaScript is deactivated in your browser.
    Some features are only accessible with active JavaScript.")
end

Given(/^I visit the landing page with activated javascript$/) do
  visit root_path
end

Then(/^I should see no javascript\-deactivated\-warning$/) do
  page.should_not have_content("JavaScript is deactivated in your browser.
    Some features are only accessible with active JavaScript.")
end

