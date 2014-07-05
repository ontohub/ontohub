require 'integration_test_helper'

class VisitOntologyTest < ActionController::IntegrationTest

=begin

  def sign_in_as(user, password)
    user = User.create(:password => password, :password_confirmation => password, :email => user)
    user.confirmed_at = Time.now
    user.save!
    visit '/'
    click_link_or_button('Log in')
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => password
    click_link_or_button('Sign in')
    user
  end

  def list_ontologies()
    visit '/ontologies'
    assert page.has_content?('Ontologies')
    assert page.has_content?('Cat')
    assert page.has_content?('Generations')
    assert page.has_content?('Pizza')
  end

  def filter_ontologies(cat, gen, piz, query)
    fill_in 'Ontology iri or name', :with => query
    click_button 'Search ontology'
    assert page.has_content?('Ontologies')
    assert !cat ^ page.has_content?('Cat')
    assert !gen ^ page.has_content?('Generations')
    assert !piz ^ page.has_content?('Pizza')
  end

  def visit_ontology_tab(name, list)
    click_link name
    list.each do |item|
      assert page.has_content?(item), "missing content '#{item}'"
    end
  end

  def visit_ontology(name)
    visit_ontology_tab(name, ['Symbols', 'Children', 'Entities', 'Versions', 'Metadata', 'Comments', 'URI', 'Name', 'Language', 'Logic', 'Owner', 'Created', 'Updated', 'Hets status'])
  end

  test "listing ontologies" do
    list_ontologies()
    filter_ontologies(true,  false, false, 'Cat')
    filter_ontologies(false, true,  false, 'Generations')
    filter_ontologies(false, false, true,  'Pizza')
    filter_ontologies(true,  false, false, 'clif')
    filter_ontologies(false, true,  true,  'owl')
  end

  test "visiting a single ontology" do
    FactoryGirl.create :single_ontology, :name => 'Cat'

    visit '/ontologies'

    assert page.has_content?('Ontologies')
    assert page.has_content?('Cat')

    visit_ontology("Cat")
    visit_ontology_tab("Sentences", ["Name", "Text"])
    visit_ontology_tab("Entities", ["Text", "Kind", "Name", "URI", "Range"])
    visit_ontology_tab("Versions", ["Created", "Source", "Uploaded by", "State", "Error"])
    visit_ontology_tab("Metadata", ["Key", "Value", "Last editor", "Updated"])
    visit_ontology_tab("Comments", [])

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

=end

end
