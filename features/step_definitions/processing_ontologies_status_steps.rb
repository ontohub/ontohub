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

Transform /^(-?\d+)$/ do |number|
  number.to_i
end

Given(/^i have (\d+) (#{Ontology::States::STATES.join('|')}) ontologies$/) do |count, state|
  @ontology_versions = FactoryGirl.create_list(:ontology_version, count, state: state)
  @ontologies = @ontology_versions.map { |ov| ov.ontology }
  @ontologies.each do |ontology|
    expect(ontology.state).to eq(state)
  end
end

When(/^i am on the processing ontologies tab$/) do
  steps %Q{
    And i navigate to the status page
    When i click on the processing ontologies tab selector
  }
end

Then(/^i should see the processing ontologies$/) do
  encountered_names = Set.new
  all('li.status_box .first-line span a').each do |anchor|
    encountered_names << anchor.text
  end
  expect(encountered_names).to eq(@ontologies.map(&:name).to_set)
end
