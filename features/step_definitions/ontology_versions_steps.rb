Given(/^there is a distributed ontology$/) do
  @distributed_ontology = FactoryGirl.create :distributed_ontology, :with_versioned_children
end

When(/^i visit the versions tab of a child ontology$/) do
  @ontology = @distributed_ontology.children.first

  visit repository_ontology_ontology_versions_path(@ontology.repository, @ontology)
end

Then(/^i should see the corresponding versions$/) do
  id = @ontology.versions.first.id
  selector = %(small.ontology-version-state[data-ontology-version-id="#{id}"])
  expect(page).to have_css(selector)
end
