Given(/^There is an ontology$/) do
  @ontology = FactoryGirl.create :ontology
end

Given(/^there is an ontology with a pending version$/) do
  @ontology_version = FactoryGirl.create :ontology_version, state: 'pending'
  @ontology = @ontology_version.ontology
end

Given(/^I visit the detail page of the ontology$/) do
  visit locid_for(@ontology, :ontology_versions)
end

When(/^we change the state of the ontology to: (\w+)$/) do |state|
  @state = state
  @ontology_version.update_state!(state)
end

Then(/^the page should change the state on its own$/) do
  el_css = 'small.evaluation-state'
  field = 'data-id'
  field_klass = 'data-klass'
  wait_for_ajax
  within %{#{el_css}[#{field}="#{@ontology_version.id}"][#{field_klass}="OntologyVersion"]} do
    expect(find('span')).to have_content(@state)
  end
end
