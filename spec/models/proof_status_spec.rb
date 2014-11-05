require 'spec_helper'

describe ProofStatus do
  context 'Associations' do
    %i(goal_status proof_tree tactic_script).each do |association|
      it { should have_one(association) }
    end

    it { should have_and_belong_to_many(:sentences) }
  end

  context 'Validations' do
    let(:proof_status) { build :proof_status }

    it 'be valid' do
      expect(proof_status).to be_valid
    end

    %w(goal_name goal_status used_prover used_time).each do |attr|
      context "with a blank #{attr}" do
        before do
          proof_status.send("#{attr}=", nil)
        end

        it "be invalid" do
          expect(proof_status).to be_invalid
        end
      end
    end
  end
end
