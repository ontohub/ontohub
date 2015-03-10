require 'spec_helper'

describe MappingsController do
  let(:ontology) { create :linked_distributed_ontology }
  let(:mapping) { ontology.mappings.last }

  context 'on GET to show' do
    context 'requesting standard representation' do
      before do
        get :show,
          repository_id: ontology.repository.to_param,
          ontology_id: ontology.to_param,
          id: mapping.to_param
      end

      it { should respond_with :success }
      it { should render_template :show }
    end
  end
end
