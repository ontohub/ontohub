require 'spec_helper'

describe OntologyVersionsController do

  context 'OntologyVersion of a DistributedOntology' do

    let(:user) { create :user }
    let(:ontology) { create :distributed_ontology }
    let(:ontology_child) { ontology.reload; ontology.children.first }
    let(:repository) { ontology.repository }

    before do
      parse_this(user, ontology, hets_out_file('test2'))
    end

    context 'on GET to index of a child' do
      before do
        get :index, repository_id: repository.to_param, ontology_id: ontology_child.to_param
      end

      it 'should assign the parents versions' do
        expect(assigns(:versions)).to eq([ontology_child.current_version])
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

    context 'on GET to show' do
      context 'requesting json representation', api_specification: true do
        let(:ontology_version_schema) { schema_for('ontology_version') }

        before do
          get :show,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            id: version.to_param,
            format: :json
        end

        it { should respond_with :success }

        it 'respond with json content type' do
          expect(response.content_type.to_s).to eq('application/json')
        end

        it 'should return a representation that validates against the schema' do
          VCR.use_cassette 'api/json-schemata/ontology_version' do
            expect(response.body).
              to match_json_schema(ontology_version_schema)
          end
        end
      end
    end
  end

end
