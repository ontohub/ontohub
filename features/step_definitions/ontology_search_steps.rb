When(/^I visit root_path$/) do
	visit root_path
end

When(/^I click on 'Ontologies'$/) do
	click_on('Ontologies')
end

When(/^I fill in 'query' with 'Pizza'$/) do
	fill_in('query', :with => 'Pizza')
end

Then(/^I should see the text 'Dolorem temporibus aliquam sed quis porro quia. Consequatur at quis. Quod expedita corporis excepturi. Consequuntur non modi.'$/) do
	page.should have_content('Dolorem temporibus aliquam sed quis porro quia. Consequatur at quis. Quod expedita corporis excepturi. Consequuntur non modi.')
end

When(/^I click on 'Pizza'$/) do
	click_on('Pizza')
end

Then(/^I should see the text 'ontology defined in the file /default/pizza.owl'$/) do
	page.should have_content('ontology defined in the file /default/pizza.owl')
end
