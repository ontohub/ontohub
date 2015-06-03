require 'spec_helper'

describe OntologyTypesController do

  let(:ontology_type)   { create :ontology_type }
  let!(:ontology)   { create :ontology, ontology_type: ontology_type }

  context 'on GET to show' do
    context 'requesting standard representation' do
      before { get :show, id: ontology_type.to_param }

      it { should respond_with :success }
      it { should render_template :show }
    end
  end
end
