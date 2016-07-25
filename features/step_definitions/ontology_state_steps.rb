Given(/^There is an ontology$/i) do
  @ontology = FactoryGirl.create :ontology
  @ontology_version = @ontology.current_version
end

Given(/^there is an ontology with a "([^"]+)" version$/) do |state|
  @ontology_version = FactoryGirl.create :ontology_version, state: state
  @ontology = @ontology_version.ontology
  @ontology.state = state
  @ontology.save!
end

Given(/^I visit the detail page of the ontology$/) do
  visit polymorphic_path([@ontology, :ontology_versions])
end

Given(/^I visit the sub-page "([^"]+)" of the ontology$/) do |subpage|
  visit polymorphic_path([@ontology, subpage.to_sym])
end

When(/^we change the state of the ontology to: (\w+)$/) do |state|
  @state = state
  @ontology_version.update_state!(state)
end

Then(/^the page should change the state on its own$/) do
  wait_for_ajax
  steps %Q{
  Then I should see the "#{@state}" state
  }
end

Then(/^I should see the "([^"]+)" state$/) do |state|
  el_css = '.evaluation-state'
  field = 'data-id'
  field_klass = 'data-klass'
  within %{#{el_css}[#{field}="#{@ontology_version.id}"][#{field_klass}="OntologyVersion"]} do
    expect(find('span')).to have_content(state)
  end
end

Then(/^I should see the "([^"]+)" state inside of "([^"]+)"$/) do |state, inside|
  within inside do
    steps %Q{
    Then I should see the "#{state}" state
    }
  end
end
