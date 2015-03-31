require 'spec_helper'

describe Theorem do
  context 'Associations' do
    it { should have_many(:proof_attempts) }
    it { should belong_to(:proof_status) }
  end

  context 'Theorem of an ontology' do
    let(:theorem) { create :theorem }

    context 'prove_options' do
      let(:ontology) { theorem.ontology }
      let(:repository) { ontology.repository }
      let(:prove_options) { theorem.prove_options }

      it 'have the ontology name as node parameter' do
        expect(prove_options.options[:node]).to eq(ontology.name)
      end

      it 'have the theorem name as theorems parameter' do
        expect(prove_options.options[:theorems]).to eq([theorem.name])
      end

      context 'with url-maps' do
        let!(:url_maps) { [create(:url_map, repository: repository)] }
        it 'have the url-maps as url-catalog parameter' do
          expect(prove_options.options[:'url-catalog']).to eq(url_maps)
        end
      end

      context 'without url-maps' do
        it 'have no url-catalog parameter' do
          expect(prove_options.options[:'url-catalog']).to be(nil)
        end
      end
    end

    context 'state' do
      it "is 'pending'" do
        expect(theorem.state).to eq('pending')
      end
    end
  end

  context 'update_proof_status' do
    let(:success) { create :proof_status_success }
    let(:proven) { create :proof_status_proven }
    let(:unknown) { create :proof_status_unknown }

    context 'from solved status' do
      let(:theorem) { create :theorem, proof_status: success }

      context 'to solved status' do
        before { theorem.update_proof_status(proven) }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq(proven)
        end
      end

      context 'to unsolved status' do
        before { theorem.update_proof_status(unknown) }

        it 'theorem still has previous status' do
          expect(theorem.proof_status).to eq(success)
        end
      end
    end

    context 'from unsolved status' do
      let(:theorem) { create :theorem, proof_status: unknown }

      context 'to solved status' do
        before { theorem.update_proof_status(proven) }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq(proven)
        end
      end

      context 'to unsolved status' do
        before { theorem.update_proof_status(unknown) }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq(unknown)
        end
      end
    end
  end
end
