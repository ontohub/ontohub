Given(/^i am logged in as an (user|admin)$/) do |role|
  @user = FactoryGirl.create :user, admin: role == 'admin'
  login_as @user, scope: :user
end

Given(/^i navigate to the status page$/) do
  visit root_path
  click_link(@user.name)
  click_link('Status')
  # save_and_open_page
end

When(/^i click on the processing ontologies tab selector$/) do
  click_link('Processing Ontologies')
end

Then(/^i should be redirected to the corresponding tab$/) do
  url = URI.parse(current_url)
  expect("#{url.path}?#{url.query}").
    to eq(admin_status_path(tab: 'ontologies'))
end
