Feature: Ontology Search

Scenario: search for pizza

When I visit root_path
When I click on 'Ontologies'
When I fill in 'query' with 'Pizza'
Then I should see the text 'Dolorem temporibus aliquam sed quis porro quia. Consequatur at quis. Quod expedita corporis excepturi. Consequuntur non modi.'
When I click on 'Pizza'
Then I should see the text 'ontology defined in the file /default/pizza.owl'