require 'spec_helper'

describe Theorem do
  context 'Associations' do
    it { should have_many(:proof_attempts) }
    it { should belong_to(:proof_status) }
  end

  context 'Proving' do
    let(:user) { create :user }
    let(:parent_ontology) { create :distributed_ontology }

    before do
      parse_ontology(user, parent_ontology, 'prove/Simple_Implications.casl')
      stub_hets_for('prove/Simple_Implications.casl',
                    command: 'prove', method: :post)
    end

    let(:ontology) { parent_ontology.children.find_by_name('Group') }
    let(:version) { ontology.current_version }
    let(:theorem) { ontology.theorems.find_by_name('rightunit') }
    let(:other_theorem) { ontology.theorems.find_by_name('zero_plus') }

    before { theorem.prove }

    it 'the theorem is solved' do
      expect(theorem.proof_attempts.count).to eq(1)
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
