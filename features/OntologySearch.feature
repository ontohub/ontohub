Feature: OntologySearch

Scenario: I want to see all available ontologies
  Given there is an ontology
  When I open the ontologies overview page
  Then I should see all available ontologies

Scenario: I want to search for a specific ontology
  Given there is an ontology
  When I open the ontologies overview page
  When I fill in the search form
  Then I should see the ontology

Scenario: I want to search for a specific ontology which doesn't exist
  Given there is an ontology
  When I open the ontologies overview page
  When I fill in the search form
  Then I shouldnt see the ontology

Scenario: I want to filter the ontologies for ontology types
  Given there is an ontology with a type
  When I open the ontologies overview page
  When I select the type I search for
  Then I should see all ontologies with that type

Scenario: I want to filter the ontologies for projects
  Given there is an ontology in a project
  When I open the ontologies overview page
  When I select the project I search for
  Then I should see all ontologies in that project

Scenario: I want to filter the ontologies for formalities
  Given there is an ontology with a formality level
  When I open the ontologies overview page
  When I select the formality I search for
  Then I should see all ontologies with that formality level

Scenario: I want to filter the ontologies for license models
  Given there is an ontology with a license model
  When I open the ontologies overview page
  When I select the license model I search for
  Then I should see all ontologies with that license model

Scenario: I want to filter the ontologies for tasks
  Given there is an ontology with a task
  When I open the ontologies overview page
  When I select the task I search for
  Then I should see all ontologies with that task

Scenario: I want to filter the ontologies with all filters
  Given there is an ontology with all filters given
  When I open the ontologies overview page
  When I select the all filters I search for
  Then I should see all ontologies with that features

Scenario: I want to filter the ontologies for ontology types and projects
  Given there is an ontology with a type which is in a project
  When I open the ontologies overview page
  When I select the type and project I search for
  Then I should see all ontologies with that two features 

Scenario: I want to filter the ontologies and for an specific ontology name
  Given there is an ontology with a type which is in a project
  When I open the ontologies overview page
  When I select the type and project I search for
  When I fill in the search form
  Then I should see all ontologies with that two features 
  And I should see all ontologies with that name

