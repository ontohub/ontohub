Given(/^there is a distributed ontology$/i) do
  @distributed_ontology = FactoryGirl.create :distributed_ontology, :with_versioned_children
  @ontology = @distributed_ontology
  @ontology_version = @ontology.current_version
end

Given(/^there is an ontology file$/i) do
  repository = @ontology.repository
  user = repository.permissions.first.subject
  Tempfile.create('testfile') do |f|
    repository.save_file_only(f.path, @ontology.path, 'add ontology file', user)
  end
end

When(/^i visit the versions tab of a child ontology$/) do
  @ontology = @distributed_ontology.children.first

  visit repository_ontology_ontology_versions_path(@ontology.repository, @ontology)
end

Then(/^i should see the corresponding versions$/) do
  id = @ontology.versions.first.id
  selector = %(.evaluation-state[data-id="#{id}"][data-klass="OntologyVersion"])
  expect(page).to have_css(selector)
end

When(/^I visit the versions tab of the ontology$/) do
  visit repository_ontology_ontology_versions_path(@ontology.repository, @ontology)
end

Then(/^I should see a "(.*?)" button for each version$/) do |text|
  within(:css, '#ontology_versions') do
    all(:css, 'tbody > tr').each do |row|
      expect(row).to have_link(text)
    end
  end
end

Then(/^I shouldn't see a "(.*?)" button for each version$/) do |text|
  within(:css, '#ontology_versions') do
    all(:css, 'tbody > tr').each do |row|
      expect(row).not_to have_link(text)
    end
  end
end

Given(/^I have an account$/) do
  @user = FactoryGirl.create :user
end

Given(/^I have permissions to edit the ontology$/) do
  perm = FactoryGirl.create :permission, subject: @user, item: @ontology.repository
end

Then(/^I should see a "(.*?)" button for the latest version$/) do |text|
  within(:css, '#ontology_versions') do
    @edit_button = first(:css, 'tbody > tr').find_link(text)
    expect(first(:css, 'tbody > tr')).to have_link(text)
  end
end

Then(/^I should see a "(.*?)" button for every other version$/) do |text|
  within(:css, '#ontology_versions') do
    all(:css, 'tbody > tr:nth-of-type(n+2)').each do |row|
      expect(row).to have_link(text)
    end
  end
end

Given(/^there is a newer "(.*?)" version$/) do |state|
  @ontology_version = FactoryGirl.create :ontology_version, state: state, ontology: @ontology
  @ontology.state = state
  @ontology.save!
end

When(/^I click the edit button$/) do
  @edit_button.click
end

Then(/^I should see edit page of the ontology$/) do
  expect(page).to have_content('Edit mode')
end
