require 'integration_test_helper' 

class OntologyTest < ActionController::IntegrationTest

  def list_ontologies()
    visit '/ontologies'
    assert page.has_content?('Ontologies')
    assert page.has_content?('Cat')
    assert page.has_content?('Generations')
    assert page.has_content?('Pizza')
  end

  def filter_ontologies(cat, gen, piz, query)
    fill_in 'Ontology\'s uri or name', :with => query
    click_button 'Search ontology'
    assert page.has_content?('Ontologies')
    assert !cat ^ page.has_content?('Cat')
    assert !gen ^ page.has_content?('Generations')
    assert !piz ^ page.has_content?('Pizza')
  end

  def visit_ontology(name)
    click_link name
    assert page.has_content?('Overview')
    assert page.has_content?('URI')
    assert page.has_content?('Name')
    assert page.has_content?('Language')
    assert page.has_content?('Owner')
    assert page.has_content?('Created')
    assert page.has_content?('Updated')
    assert page.has_content?('Hets status')
  end

  test "listing ontologies" do
    list_ontologies()
    filter_ontologies(true,  false, false, 'Cat')
    filter_ontologies(false, true,  false, 'Generations')
    filter_ontologies(false, false, true,  'Pizza')
    filter_ontologies(true,  false, false, 'clif')
    filter_ontologies(false, true,  true,  'owl')
  end

  test "visiting ontologies as unkown user" do
    list_ontologies()
    visit_ontology("Cat")

    # Check specific fields
    assert page.has_content?('Comments')
  end

  test "visiting ontologies as admin" do
    list_ontologies()
    visit_ontology("Cat")

    # Check specific fields
    #assert page.has_content?('Permissions')
    #assert page.has_content?('New version')
    #assert page.has_content?('Edit')
    #assert page.has_content?('Delete')
  end

  #check 'Exclusive'
end