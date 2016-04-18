Given(/^there is an ontology$/) do
  @ontology = FactoryGirl.create :ontology
end

When(/^I open the ontologies overview page$/) do
  visit ontologies_path
end

Then(/^I should see all available ontologies$/) do
  page.should have_content(@ontology.name)
end

Given(/^the ontology I want to search for$/) do
  @name = 'Foobar'
  @ontology = FactoryGirl.create :ontology, name: @name
end

When(/^I fill in the search form$/) do
  within '#search_form_div' do
    fill_in 'query', with: @name
  end
end

Then(/^I should see the ontology$/) do
  page.should have_content(@name)
end

Then(/^I shouldnt see the ontology$/) do
  page.should_not have_content("{#@ontology.name}" + 'Foobar')
end

Given(/^there is an ontology with a '([^']+)'$/) do |filterable|
  @filterable = FactoryGirl.create filterable.to_sym
  @ontology = FactoryGirl.create :ontology, filterable.to_sym => @filterable
end

Given(/^there is an ontology with '([^']+)'$/) do |filterable|
  @filterable = FactoryGirl.create filterable.singularize.to_sym
  @ontology = FactoryGirl.create :ontology, filterable.to_sym => [@filterable]
end

When(/^I select the '([^']+)' I search for$/) do |filterable|
  within '#search_form_div' do
    select @filterable.name, from: "_#{filterable}"
  end
end

When(/^I select the type I search for$/) do
  within '#search_form_div' do
    select @ontology_type.name, from: '_ontology_type'
  end
end

When(/^I select the project I search for$/) do
  within '#search_form_div' do
    select @project.name, from: '_project'
  end
end

Then(/^I should see all ontologies with that '[^']+'$/) do
  page.should have_content(@ontology.name)
  page.should have_content(@filterable.name)
end

Given(/^there is an ontology with all filters given$/) do
  @ontology_type = FactoryGirl.create :ontology_type
  @project = FactoryGirl.create :project
  @formality_level = FactoryGirl.create :formality_level
  @license_model = FactoryGirl.create :license_model
  @task = FactoryGirl.create :task
  @ontology = FactoryGirl.create :ontology, ontology_type: @ontology_type,
  projects: [@project], formality_level: @formality_level,
  license_models: [@license_model], tasks: [@task]
end

When(/^I select the all filters I search for$/) do
  within '#search_form_div' do
    select @ontology_type.name, from: '_ontology_type'
    select @project.name, from: '_project'
    select @formality_level.name, from: '_formality_level'
    select @license_model.name, from: '_license_model'
    select @task.name, from: '_task'
  end
end

Then(/^I should see all ontologies with that features$/) do
  page.should have_content(@ontology.name)
  page.should have_content(@ontology_type.name)
  page.should have_content(@project.name)
  page.should have_content(@formality_level.name)
  page.should have_content(@license_model.name)
  page.should have_content(@task.name)
end

Given(/^there is an ontology with a type which is in a project$/) do
  @ontology_type = FactoryGirl.create :ontology_type
  @project = FactoryGirl.create :project
  @ontology = FactoryGirl.create :ontology, ontology_type: @ontology_type,
  projects: [@project]
end

When(/^I select the type and project I search for$/) do
  within '#search_form_div' do
    select @ontology_type.name, from: '_ontology_type'
    select @project.name, from: '_project'
  end
end

Then(/^I should see all ontologies with that two features$/) do
  page.should have_content(@ontology_type.name)
  page.should have_content(@project.name)
end

Then(/^I should see all ontologies with that name$/) do
  page.should have_content(@ontology.name)
end

Given(/^there are at least two repositories$/) do
  @repository_one = FactoryGirl.create :repository, name: 'RepoOne'
  @repository_two = FactoryGirl.create :repository, name: 'RepoTwo'
end

Given(/^there are at least two ontologies$/) do
  @ontology_one = FactoryGirl.create :ontology, name: 'OntologyOne',
  repository: @repository_one
  @ontology_two = FactoryGirl.create :ontology, name: 'OntologyTwo',
  repository: @repository_two
end

When(/^I open the repositories overview page$/) do
  visit repositories_path
end

When(/^I select a repository$/) do
  within 'ul.list-group' do
    click_link(@repository_one.name)
  end
end

When(/^I select the ontologies tab$/) do
  within 'ul.nav.nav-tabs' do
    click_link('Ontologies')
  end
end

Then(/^I should see all ontologies in that repository$/) do
  page.should have_content(@ontology_one.name)
end

Then(/^I should not see ontologies from other repositories$/) do
  page.should_not have_content(@ontology_two.name)
  page.should_not have_content(@repository_two.name)
end

Given(/^there are at least two ontologies with ontology types$/) do
  @ontology_type = FactoryGirl.create :ontology_type
  @ontology_one = FactoryGirl.create :ontology, name: 'OntologyOne',
  repository: @repository_one, ontology_type: @ontology_type
  @ontology_two = FactoryGirl.create :ontology, name: 'OntologyTwo',
  repository: @repository_two, ontology_type: @ontology_type
end

Then(/^I should see all ontologies in that repository with that type$/) do
  page.should have_content(@ontology_one.name)
  page.should have_content(@ontology_type.name)
end

Then(/^I should not see ontologies from other repositories with that type$/) do
  page.should_not have_content(@ontology_two.name)
end

Given(/^there are at least two ontologies with ontology tpyes and projects$/) do
  @ontology_type = FactoryGirl.create :ontology_type
  @project = FactoryGirl.create :project
  @ontology_one = FactoryGirl.create :ontology, name: 'OntologyOne',
  repository: @repository_one, ontology_type: @ontology_type, projects:
  [@project]
  @ontology_two = FactoryGirl.create :ontology, name: 'OntologyTwo',
  repository: @repository_two, ontology_type: @ontology_type, projects:
  [@project]
end

Then(/^I should see all ontologies in that repository with that type, in that project$/) do
  page.should have_content(@ontology_one.name)
  page.should have_content(@ontology_type.name)
  page.should have_content(@project.name)
end

Then(/^I should not see ontologies from other repositories with that type, in that project$/) do
  page.should_not have_content(@ontology_two.name)
end

When(/^I type in a ontology name I'm searching for which is in the repository$/) do
  within '#search_form_div' do
    fill_in 'query', with: @ontology_one.name
  end
end

When(/^I type in a ontology name I'm searching for which is not existing$/) do
  within '#search_form_div' do
    fill_in 'query', with: 'OntologyThree'
  end
end

Then(/^I should not see the ontology$/) do
  within '#search_response' do
    page.should_not have_content('OntologyThree')
  end
end

Given(/^there is an ontology with a category$/) do
  @ont_with_cat = FactoryGirl.create :ontology
  @cat = FactoryGirl.create :category
  @ont_with_cat.categories << @cat
end

Then(/^I should see all ontologies with a category$/) do
  page.should have_content(@ont_with_cat.name)
end

Given(/^I am logged in as the owner of a private repository$/) do
  @repo = FactoryGirl.create :private_repository
  @user = @repo.permissions.first.subject
  login_as @user, :scope => :user
end

Given(/^I am not logged in as the owner of a private repository$/) do
  @repo = FactoryGirl.create :private_repository
  @user = FactoryGirl.create :user
  login_as @user, :scope => :user
end

Given(/^there is an ontology in this repository$/) do
  @ontology = FactoryGirl.create :ontology, repository: @repo
  @repo.ontologies << @ontology
end

Then(/^I should see the ontology in this repository$/) do
  page.should have_content(@ontology.name)
end

Then(/^I shouldn't see the ontology in this repository$/) do
  page.should_not have_content(@ontology.name)
end

When(/^I search for this ontology$/) do
  within '#search_form_div' do
    fill_in 'query', with: @ontology.name
  end
end
