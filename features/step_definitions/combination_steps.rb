Given(/^that I have a valid API\-Key$/) do
  @api_key = FactoryGirl.create :api_key
  @user = @api_key.user
end

Given(/^that I have an invalid API\-Key$/) do
  @api_key = FactoryGirl.create :api_key, :invalid
  @user = @api_key.user
end

Given(/^I have a repository with path: "([^"]+)"$/) do |path|
  permission =
    if @user
      FactoryGirl.create :permission, subject: @user
    else
      FactoryGirl.create :permission
    end
  @repository = permission.item
  @repository.path = path
  @repository.save!
end

Given(/^I know of a repository with path: "([^"]+)"$/) do |path|
  @repository = FactoryGirl.create :repository, path: path
end

Given(/^I have (\d+) ontologies$/) do |number|
  @ontologies = (1..number.to_i).to_a.
    map { FactoryGirl.create :ontology }
end

When(/^I create a combination via the API of these ontologies$/) do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header Api::V1::Base::API_KEY_HEADER, @api_key.try(:key)
  request "/#{@repository.path}///combinations",\
    method: :post,
    input: {
      nodes: @ontologies.map { |o| locid_for(o) }
    }.to_json
end

When(/^I create a combination via the API with these:$/) do |table|
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header Api::V1::Base::API_KEY_HEADER, @api_key.try(:key)
  request "/#{@repository.path}///combinations",\
    method: :post,
    input: table.hashes.first.to_json
end

Then(/^I should get a (\d+) response$/) do |number|
  expect(last_response.status).to eq(number.to_i)
end

Then(/^a location\-header to the combination\-ontology$/) do
  expect(last_response.headers["Location"]).to eq(Ontology.last.locid)
end

Then(/^a location\-header to an action$/) do
  expect(last_response.headers["Location"]).
    to eq(action_iri_path(Action.last))
end

Then(/^the body should be valid for a (\d+) combination-response/) do |status|
  schema = schema_for("repository/combinations/POST/response/#{status}")
  VCR.use_cassette "api/json-schemata/repository/combinations/#{status}" do
    expect(last_response.body).to match_json_schema(schema)
  end
end
