When(/^I create a Repository with name "([^"]+)"$/) do |name|
  @repository = FactoryGirl.create :repository, name: name
end

When(/^I upload an ontology with a Theorem$/) do
  @ontology_prototype = FactoryGirl.build :ontology, repository: @repository
  @theorem_prototype = FactoryGirl.build :theorem, ontology: @ontology_prototype

  @ontology = @ontology_prototype.dup
  @theorem = @theorem_prototype.dup
  @theorem.ontology = @ontology

  @ontology.save!
  @theorem.save!
end

When(/^I upload the same ontology again$/) do
  @ontology = @ontology_prototype.dup
  @ontology.repository = @repository

  @theorem = @theorem_prototype.dup
  @theorem.ontology = @ontology

  @ontology.save!
  @theorem.save!
end

When(/^I attempt to prove the Theorem$/) do
  FactoryGirl.create :proof_attempt, :proven, theorem: @theorem
end

When(/^I destroy the repository$/) do
  @repository.destroy
end

When(/^I visit the proof attempt's loc\/id$/) do
  visit ProofAttempt.last.locid
end

Then(/^a headline should include "Proof Attempt of \[the theorem's name\]"$/) do
  search_string = "Proof Attempt of #{@theorem.name}"
  expect(page.find('h3').text).to include(search_string)
end
