def build_version_for(ontology)
  commit_oid = '1'*40
  ontology.versions.build(
    {commit_oid: commit_oid,
     commit: FactoryGirl.create(:commit, commit_oid: commit_oid),
     basepath: File.basepath(ontology.path),
     file_extension: File.extname(ontology.path),
     fast_parse: false},
    {without_protection: true})
end

Given(/^I have uploaded a(.*) ontology$/) do |type|
  steps %Q{
  Given I have an account
  And I am logged in
  And there is a#{type} ontology
  And I have permissions to edit the ontology
  And there is an ontology file
  }
end

Given(/^Children of the ontology have been deleted$/i) do
  @deleted_child = @ontology.children.last
  @deleted_child.present = false
  @deleted_child.save!

  build_version_for(@ontology).save!
  @ontology.children.each do |child|
    build_version_for(child).save!
  end
end

Given(/^Children of the ontology have been restored$/i) do
  @deleted_child.present =true
  @deleted_child.save!

  build_version_for(@ontology).save!
  @ontology.children.each do |child|
    build_version_for(child).save!
  end
end

When(/^I visit the file view of the ontology$/i) do
  # The request object does not contain a requested mime type, so we need to
  # stub this.
  allow_any_instance_of(FilesController).
    to receive(:existing_file_requested_as_html?).
    and_return(true)
  visit repository_tree_path(@ontology.repository, path: @ontology.path)
end

Then(/^I should see all the file's ontologies$/i) do
  # The file defines the DistributedOntolgy and its children.
  number = 1 + @ontology.children.count

  expect(page.find('#ontology-list-headline').text).to match(/\s+#{number}\s+/)
  expect(page).to have_selector('ul.ontology-list > li', count: number)
end
