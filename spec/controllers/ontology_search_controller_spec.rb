require 'spec_helper'

describe OntologySearchController do

  describe 'GET search with no ontology restriction' do
    it 'responds with all ontologies' do
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'

      get :search, { keywords: [] }

      should respond_with :success
    end
  end

  # searches for an ontology
  #     created for an identified class of purposes (id = 1)
  describe 'GET search with 1 class expression' do
    it 'responds with selected ontologies' do
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'

      get :search, { keywords: ['{"item":"4","type":"Task","role":null}'] }

      should respond_with :success
    end
  end

  # searches for an ontology
  #     in a logic whose name includes "cas",
  #     with a symbol whose name inlcudes "cas",
  #     or whose name includes "cas"
  describe 'GET search with 1 identifier fragment' do
    it 'responds with selected ontologies' do
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'

      get :search, { keywords: ['{"item":"cas","type":"Mixed","role":null}'] }

      should respond_with :success
    end
  end

  # searches for an ontology
  #      with a query containing the above two ontology restrictions
  describe 'GET search with 2 ontology restrictions' do
    it 'responds with selected ontologies' do
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'

      get :search, { keywords: ['{"item":"4","type":"Task","role":null}','{"item":"cas","type":"Mixed","role":null}'] }

      should respond_with :success
    end
  end

  # search for an ontology
  #     with a query containing a malformed ontology restriction
  describe 'GET search with 1 malformed ontology restriction' do
    it 'responds with a malformed request exception' do
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'

      expect { get :search, { keywords: [1] } }.to raise_error(ActionController::RoutingError)
    end
  end

  describe 'GET filter_map' do
    it 'renders a map of filters in json' do
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'

      get :filters_map

      should respond_with :success
    end
  end

end
