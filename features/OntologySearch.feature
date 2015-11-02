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
  Given there is an ontology with a 'ontology_type'
  When I open the ontologies overview page
  When I select the 'ontology_type' I search for
  Then I should see all ontologies with that 'type'

Scenario: I want to filter the ontologies for projects
  Given there is an ontology with 'projects'
  When I open the ontologies overview page
  When I select the 'project' I search for
  Then I should see all ontologies with that 'project'

Scenario: I want to filter the ontologies for formalities
  Given there is an ontology with a 'formality_level'
  When I open the ontologies overview page
  When I select the 'formality_level' I search for
  Then I should see all ontologies with that 'formality level'

Scenario: I want to filter the ontologies for license models
  Given there is an ontology with 'license_models'
  When I open the ontologies overview page
  When I select the 'license_model' I search for
  Then I should see all ontologies with that 'license model'

Scenario: I want to filter the ontologies for tasks
  Given there is an ontology with 'tasks'
  When I open the ontologies overview page
  When I select the 'task' I search for
  Then I should see all ontologies with that 'task'

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

Scenario: I want to search for ontologies in a repository
  Given there are at least two repositories
  Given there are at least two ontologies
  When I open the repositories overview page
  When I select a repository
  When I select the ontologies tab
  Then I should see all ontologies in that repository
  And I should not see ontologies from other repositories

Scenario: I want to filter ontologies in a repository for ontology types
  Given there are at least two repositories
  Given there are at least two ontologies with ontology types
  When I open the repositories overview page
  When I select a repository
  When I select the ontologies tab
  Then I should see all ontologies in that repository
  When I select the type I search for
  Then I should see all ontologies in that repository with that type
  And I should not see ontologies from other repositories with that type

Scenario: I want to filter ontologies in a repository with different filters
  Given there are at least two repositories
  Given there are at least two ontologies with ontology tpyes and projects
  When I open the repositories overview page
  When I select a repository
  When I select the ontologies tab
  Then I should see all ontologies in that repository
  When I select the type I search for
  When I select the project I search for
  Then I should see all ontologies in that repository with that type, in that project
  And I should not see ontologies from other repositories with that type, in that project

Scenario: I want to search for a existing ontology in a repository
  Given there are at least two repositories
  Given there are at least two ontologies
  When I open the repositories overview page
  When I select a repository
  When I select the ontologies tab
  Then I should see all ontologies in that repository
  And I should not see ontologies from other repositories
  When I type in a ontology name I'm searching for which is in the repository
  Then I should see the ontology

Scenario: I want to search for a not existing ontology in a repository
  Given there are at least two repositories
  Given there are at least two ontologies
  When I open the repositories overview page
  When I select a repository
  When I select the ontologies tab
  Then I should see all ontologies in that repository
  And I should not see ontologies from other repositories
  When I type in a ontology name I'm searching for which is not existing
  Then I should not see the ontology

Scenario: I want to search for a ontology with a category
  Given there is an ontology with a category
  When I open the ontologies overview page
  Then I should see all ontologies with a category