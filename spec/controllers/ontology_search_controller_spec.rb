require 'spec_helper'

describe OntologySearchController do

  describe 'GET search with no ontology restriction' do
    it 'responds with all ontologies' do
      @request.env['CONTENT_TYPE'] = 'application/json'

      get :search

      should respond_with :success
      expect(assigns (:search_response)).to eq(Ontology.scoped)
    end
  end
end
