Given(/^that I have requested the creation of a combination$/) do
  steps %Q{
  Given that I have a valid API-Key
  And I have a repository with path: "default"
  And I have 2 ontologies
  When I create a combination via the API of these ontologies
  Then I should get a 202 response
  And a location-header to an action
  And the body should be valid for a 202 combination-response
  }
end

And(/^that I have a corresponding action$/) do
  action_id = last_response.headers['Location'].split('/').last.to_i
  @action = Action.find(action_id)
end

When(/^I request that action$/) do
  header 'Accept', 'application/json'
  request action_iri_path(@action)
end

Then(/^the body should be valid for an? (\w+)-response/) do |resource|
  schema = schema_for(resource)
  VCR.use_cassette "api/json-schemata/#{resource}" do
    expect(last_response.body).to match_json_schema(schema)
  end
end

Then(/^it should contain a field "([^"]+)" of "([^"]+)"$/) do |field, val|
  json = ActiveSupport::JSON.decode(last_response.body)
  expect(json[field]).to eq(val)
end

And(/^the combination is ready$/) do
  ActionWorker.drain
  @combination_ontology = @repository.ontologies.
    where(name: 'Combinations').first!
  @combination_ontology.state = 'done'
  @combination_ontology.save!
end

And(/^it should redirect to the combination-ontology$/) do
  locid = @combination_ontology.locid
  expect(last_response.headers['Location']).
    to eq(locid)
  steps %Q{
    And it should contain a field "location" of "#{locid}"
  }
end
