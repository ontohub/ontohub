require 'spec_helper'

describe OntologySearchController do

  describe "GET search" do
    it "searches for ontologies with the given keywords" do
      @request.env["HTTP_ACCEPT"] = "application/json"
      @request.env["CONTENT_TYPE"] = "application/json"
      get :search, { keywords: [] }


      expect(response.status).to eq(200)
    end
  end

  describe "GET filter_map" do
    it "renders a map of filters in json" do
      @request.env["HTTP_ACCEPT"] = "application/json"
      @request.env["CONTENT_TYPE"] = "application/json"
      get :filters_map
      expect(response.status).to eq(200)
    end
  end

end
