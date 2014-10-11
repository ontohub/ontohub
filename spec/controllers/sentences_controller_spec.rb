require 'spec_helper'

describe SentencesController do
  let!(:sentence) { FactoryGirl.create :sentence }
  let!(:ontology) { sentence.ontology }

  context 'on GET to index' do
    render_views

    before do
      get :index,
        repository_id: ontology.repository.to_param,
        ontology_id: ontology.to_param
    end

    it { should respond_with :success }
    it { should render_template :index }
    it { should render_template 'sentences/_sentence' }
  end
end
