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

      context 'on a private repository' do
        before do
          repository.access = 'private_rw'
          repository.save!
        end

        it 'have an existing access-token parameter' do
          expect(prove_options.options[:'access-token']).to be_present
        end
        it 'have the access token as access-token parameter' do
          expect(prove_options.options[:'access-token']).
            to eq(repository.access_tokens.first.to_s)
        end
      end

      context 'with url-maps' do
        let!(:url_maps) { [create(:url_map, repository: repository)] }
        it 'have the url-maps as url-catalog parameter' do
          expect(prove_options.options[:'url-catalog']).to eq(url_maps.join(','))
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

  context 'update_proof_status!' do
    let(:open) { create :proof_status_open }
    let(:success) { create :proof_status_success }
    let(:unknown) { create :proof_status_unknown }
    let(:disproven_on_subset) { create :proof_status_csas }
    let(:disproven) { create :proof_status_csa }
    let(:proven) { create :proof_status_proven }
    let(:contr) { create :proof_status_contr}

    context 'from status open' do
      let(:theorem) do
        proof_attempt = create :proof_attempt, proof_status: open
        proof_attempt.theorem
      end

      %i(open unknown success disproven_on_subset disproven proven contr).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status #{status}" do
            expect(theorem.proof_status).to eq(send(status))
          end
        end
      end
    end

    context 'from status unknown' do
      let(:theorem) do
        proof_attempt = create :proof_attempt, proof_status: unknown
        proof_attempt.theorem
      end

      %i(open).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status unknown" do
            expect(theorem.proof_status).to eq(unknown)
          end
        end
      end

      %i(success disproven_on_subset disproven proven contr).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status #{status}" do
            expect(theorem.proof_status).to eq(send(status))
          end
        end
      end
    end

    context 'from status success' do
      let(:theorem) do
        proof_attempt = create :proof_attempt, proof_status: success
        proof_attempt.theorem
      end

      %i(open unknown).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status success" do
            expect(theorem.proof_status).to eq(success)
          end
        end
      end

      %i(success disproven_on_subset disproven proven contr).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status #{status}" do
            expect(theorem.proof_status).to eq(send(status))
          end
        end
      end
    end

    context 'from status disproven_on_subset' do
      let(:theorem) do
        proof_attempt = create :proof_attempt, proof_status: disproven_on_subset
        proof_attempt.theorem
      end

      %i(open unknown success).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status unknown" do
            expect(theorem.proof_status).to eq(disproven_on_subset)
          end
        end
      end

      %i(disproven_on_subset disproven proven contr).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status #{status}" do
            expect(theorem.proof_status).to eq(send(status))
          end
        end
      end
    end

    context 'from status disproven' do
      let(:theorem) do
        proof_attempt = create :proof_attempt, proof_status: disproven
        proof_attempt.theorem
      end

      %i(open unknown success disproven_on_subset).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status unknown" do
            expect(theorem.proof_status).to eq(disproven)
          end
        end
      end

      %i(disproven contr).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status #{status}" do
            expect(theorem.proof_status).to eq(send(status))
          end
        end
      end
    end

    context 'from status proven' do
      let(:theorem) do
        proof_attempt = create :proof_attempt, proof_status: proven
        proof_attempt.theorem
      end

      %i(open unknown success disproven_on_subset).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status unknown" do
            expect(theorem.proof_status).to eq(proven)
          end
        end
      end

      %i(proven contr).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status #{status}" do
            expect(theorem.proof_status).to eq(send(status))
          end
        end
      end
    end

    context 'from status contr' do
      let(:theorem) do
        proof_attempt = create :proof_attempt, proof_status: contr
        proof_attempt.theorem
      end

      %i(open unknown success disproven_on_subset disproven proven contr).each do |status|
        context "to status #{status}" do
          before { create :proof_attempt, theorem: theorem, proof_status: send(status) }

          it "theorem has status unknown" do
            expect(theorem.proof_status).to eq(contr)
          end
        end
      end
    end

    context '- contradictory -' do
      [%w(THM THM), %w(CSA CSA)].each do |statuses|
        context "#{statuses.first} and #{statuses.last} -" do
          let!(:proof_attempt1) do
            create :proof_attempt, proof_status: ProofStatus.find(statuses.first)
          end
          let!(:theorem) { proof_attempt1.theorem }
          let!(:proof_attempt2) do
            create :proof_attempt,
                   proof_status: ProofStatus.find(statuses.last),
                   theorem: theorem
          end

          it "theorem is #{statuses.first}" do
            expect(theorem.proof_status.identifier).to eq(statuses.first)
          end
        end
      end

      [%w(THM CSAS), %w(CSA CSAS), %w(CSAS THM), %w(CSAS CSA)].each do |statuses|
        context "#{statuses.first} and #{statuses.last} -" do
          let!(:proof_attempt1) do
            create :proof_attempt, proof_status: ProofStatus.find(statuses.first)
          end
          let!(:theorem) { proof_attempt1.theorem }
          let!(:proof_attempt2) do
            create :proof_attempt,
                   proof_status: ProofStatus.find(statuses.last),
                   theorem: theorem
          end

          it "theorem is #{statuses.select { |s| s != 'CSAS'}.first}" do
            expect(theorem.proof_status.identifier).
              to eq(statuses.select { |s| s != 'CSAS'}.first)
          end
        end
      end

      [%w(THM CSA), %w(CSA THM)].each do |statuses|
        context "#{statuses.first} and #{statuses.last} -" do
          let!(:proof_attempt1) do
            create :proof_attempt, proof_status: ProofStatus.find(statuses.first)
          end
          let!(:theorem) { proof_attempt1.theorem }
          let!(:proof_attempt2) do
            create :proof_attempt,
                   proof_status: ProofStatus.find(statuses.last),
                   theorem: theorem
          end

          it 'theorem is CONTR' do
            expect(theorem.reload.proof_status.identifier).to eq('CONTR')
          end
        end
      end
    end
  end
end
