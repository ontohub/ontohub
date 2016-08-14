Given(/^my subject is a (.+)$/) do |kind|
  @subject =
    case kind
    when 'SingleOntology'
      FactoryGirl.create :single_ontology
    when 'DistributedOntology'
      FactoryGirl.create :distributed_ontology
    when 'child Ontology'
      FactoryGirl.create(:distributed_ontology, :with_children).children.first
    when 'Symbol'
      FactoryGirl.create :symbol
    when 'Mapping'
      source_ontology = FactoryGirl.create :single_ontology
      target_ontology = FactoryGirl.create :single_ontology
      FactoryGirl.create :mapping, source: source_ontology,
                                   target: target_ontology
    when 'Theorem'
      FactoryGirl.create :theorem
    when 'ProofAttempt'
      FactoryGirl.create :proof_attempt
    when 'ProverOutput'
      FactoryGirl.create :prover_output
    end
end

@require_accept_html
Given(/^I visit my subject's locid$/) do
  visit @subject.locid
end

@require_accept_html
Given(/^I visit my subject's (\S+) command$/) do |command|
  visit polymorphic_path([@subject, command])
end

Then(/^the page title should include "(\S+)"$/) do |text|
  expect(page.title).to include(text)
end

Then(/^the page title should include the subject's (\S+)$/) do |attribute|
  expect(page.title).to include(@subject.send(attribute))
end

Then(/^the page title should include the subject's ontology's (\S+)$/) do |attribute|
  ontology = @subject.ontology
  expect(page.title).to include(ontology.send(attribute))
end

Then(/^the active tab in the navigation level (\d+) should be "([^"]+)"$/) do |level, text|
  expect(page.find_all(".nav_tab_level#{level} > .nav-tabs > li.active").last.text).
    to eq(text)
end

Then(/^a headline should include "Proof Attempt of \[the corresponding theorem's name\]"$/) do
  theorem = @subject.theorem
  search_string = "Proof Attempt of #{theorem.name}"
  expect(page.find('h3').text).to include(search_string)
end

Then(/^a headline should include "Prover Output for \[theorem's name\]'s proof attempt #\[proof attempt's number\]"$/) do
  proof_attempt = @subject.proof_attempt
  theorem = proof_attempt.theorem
  search_string = "Prover Output for #{theorem.name}'s proof attempt ##{proof_attempt.number}"
  expect(page.find('h3').text).to include(search_string)
end
