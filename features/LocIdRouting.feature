Feature: LocId Routing

Scenario: Visiting a SingleOntology
  Given my subject is a SingleOntology
  And I visit my subject's locid
  Then I should get a response with a status of 200
  And the page title should include the subject's name

Scenario: Visiting a DistributedOntology
  Given my subject is a DistributedOntology
  And I visit my subject's locid
  Then I should get a response with a status of 200
  And the page title should include the subject's name

Scenario: Visiting a child Ontology
  Given my subject is a child Ontology
  And I visit my subject's locid
  Then I should get a response with a status of 200
  And the page title should include the subject's name

Scenario: Visiting a Mapping
  Given my subject is a Mapping
  And I visit my subject's locid
  Then I should get a response with a status of 200
  And the page title should include the subject's iri

Scenario: Visiting a Symbol
  Given my subject is a Symbol
  And I visit my subject's locid
  Then I should get a response with a status of 200
  And the page title should include the subject's ontology's name
  And the page title should include "Symbols"

Scenario: Visiting the Axioms index
  Given my subject is a SingleOntology
  And I visit my subject's axioms command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the active tab in the navigation level 2 should be "Axioms"

Scenario: Visiting the Theorems index
  Given my subject is a SingleOntology
  And I visit my subject's theorems command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the page title should include "Theorems"
  And the active tab in the navigation level 2 should be "Theorems"

Scenario: Visiting the Comments
  Given my subject is a SingleOntology
  And I visit my subject's comments command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the page title should include "Comments"
  And the active tab in the navigation level 1 should be "Comments"

Scenario: Visiting the Projects
  Given my subject is a SingleOntology
  And I visit my subject's projects command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the active tab in the navigation level 1 should be "Metadata"
  And the active tab in the navigation level 2 should be "Projects"

Scenario: Visiting the Tasks
  Given my subject is a SingleOntology
  And I visit my subject's tasks command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the active tab in the navigation level 1 should be "Metadata"
  And the active tab in the navigation level 2 should be "Tasks"

Scenario: Visiting the LicenseModels
  Given my subject is a SingleOntology
  And I visit my subject's license_models command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the active tab in the navigation level 1 should be "Metadata"
  And the active tab in the navigation level 2 should be "License Models"

Scenario: Visiting the FormalityLevels
  Given my subject is a SingleOntology
  And I visit my subject's formality_levels command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the active tab in the navigation level 1 should be "Metadata"
  And the active tab in the navigation level 2 should be "Formality Levels"

Scenario: Visiting the OntologyVersions
  Given my subject is a SingleOntology
  And I visit my subject's ontology_versions command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the page title should include "Ontology_versions"
  And the active tab in the navigation level 1 should be "Versions"

Scenario: Visiting the Graphs
  Given my subject is a SingleOntology
  And I visit my subject's graphs command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the page title should include "Graphs"
  And the active tab in the navigation level 1 should be "Graphs"

Scenario: Visiting the Mappings index
  Given my subject is a SingleOntology
  And I visit my subject's mappings command
  Then I should get a response with a status of 200
  And the page title should include the subject's name
  And the page title should include "Mappings"
  And the active tab in the navigation level 1 should be "Mappings"

Scenario: Visiting a Theorem / the ProofAttempts index
  Given my subject is a Theorem
  And I visit my subject's locid
  Then I should get a response with a status of 200
  And the page title should include the subject's ontology's name
  And the page title should include "Theorems"

Scenario: Visiting a ProofAttempt
  Given my subject is a ProofAttempt
  And I visit my subject's locid
  Then I should get a response with a status of 200
  And a headline should include "Proof Attempt of [the corresponding theorem's name]"

Scenario: Visiting a ProverOutput
  Given my subject is a ProverOutput
  And I visit my subject's locid
  Then I should get a response with a status of 200
  And a headline should include "Prover Output for [theorem's name]'s proof attempt #[proof attempt's number]"
