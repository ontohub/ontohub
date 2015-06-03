Given(/^there is a single ontology$/) do
  @ontology = FactoryGirl.create(:single_unparsed_ontology)
end

Given(/^there is a single\-in\-distributed ontology$/) do
  @parent_ontology = FactoryGirl.create(:heterogeneous_ontology)
  @ontology = @parent_ontology.children.first
end

When(/^I visit the ontology via the loc\/id$/) do
  visit @ontology.locid
end

Then(/^i should get a response with a status of (\d+)$/) do |code|
  expect(page.status_code).to eq(code)
end

Then(/^i should have an API\-command matching '([^']+)'$/) do |command|
  expect(current_path).to include("///#{command}")
end
