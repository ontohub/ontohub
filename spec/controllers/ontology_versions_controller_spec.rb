require 'spec_helper'

describe OntologyVersionsController do

  context 'OntologyVersion of a DistributedOntology' do

    let(:user) { create :user }
    let(:ontology) { create :distributed_ontology }
    let!(:version) { create :ontology_version, ontology: ontology }
    let(:ontology_child) { ontology.reload; ontology.children.first }
    let(:repository) { ontology.repository }

    before do
      parse_this(user, ontology, fixture_file('test2.xml'),
                 fixture_file('test2.pp.xml'))
    end

    context 'on GET to index of a child' do
      before do
        get :index, repository_id: repository.to_param, ontology_id: ontology_child.to_param
      end

      it 'should assign the parents versions' do
        expect(assigns(:versions)).to eq([version])
      end
    end

  end

  context 'OntologyVersion Instance' do
    let(:version) { create :ontology_version_with_file }
    let(:ontology) { version.ontology }
    let(:repository) { ontology.repository }

    context 'on GET to index' do
      before do
        get :index, repository_id: repository.to_param, ontology_id: ontology.to_param
      end

      it { should respond_with :success }

      context 'for a single ontology' do
        it 'should assign the right versions' do
          expect(assigns(:versions)).to_not be_nil
        end
      end
    end
  end

end
