 require 'spec_helper'

 describe ProofEvaluationStateUpdater do
   context 'single proof attempt from working state' do
     let(:proof_attempt) { create :proof_attempt, state: 'pending' }
     let(:theorem) { proof_attempt.theorem }

     %i(done failed processing).each do |state|
       context "to #{state}" do
         let(:pesu) { ProofEvaluationStateUpdater.new(proof_attempt, state) }
         before { pesu.call }

         it "update the state to #{state}" do
           expect(proof_attempt.state).to eq(state.to_s)
         end

         it "theorem is #{state}" do
           expect(theorem.state).to eq(state.to_s)
         end
       end
     end
   end

   context 'many proof attempts from working state' do
     let!(:proof_attempt1) { create :proof_attempt, state: 'pending' }
     let(:theorem) { proof_attempt1.theorem }
     let!(:proof_attempt2) { create :proof_attempt, theorem: theorem, state: 'pending' }

     context 'all done' do
       let(:pesu1) { ProofEvaluationStateUpdater.new(proof_attempt1, :done) }
       let(:pesu2) { ProofEvaluationStateUpdater.new(proof_attempt2, :done) }
       before { [pesu1, pesu2].each(&:call) }

       it 'change the state of the theorem to done' do
         expect(theorem.state).to eq('done')
       end
     end

     context 'first still working, last is done' do
       let(:pesu1) { ProofEvaluationStateUpdater.new(proof_attempt1, :processing) }
       let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, :processing) }
       let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, :done) }
       before { [pesu1, pesu21, pesu22].each(&:call) }

       it 'theorem is done' do
         expect(theorem.state).to eq('done')
       end
     end

     context 'first is done, last still working' do
       let(:pesu11) { ProofEvaluationStateUpdater.new(proof_attempt1, :processing) }
       let(:pesu12) { ProofEvaluationStateUpdater.new(proof_attempt1, :done) }
       let(:pesu2) { ProofEvaluationStateUpdater.new(proof_attempt2, :processing) }
       before { [pesu11, pesu12, pesu2].each(&:call) }

       it 'theorem is still done' do
         expect(theorem.state).to eq('done')
       end
     end

     context 'first failed, others done' do
       let(:pesu11) { ProofEvaluationStateUpdater.new(proof_attempt1, :processing) }
       let(:pesu12) { ProofEvaluationStateUpdater.new(proof_attempt1, :failed) }
       let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, :processing) }
       let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, :done) }
       before { [pesu11, pesu12, pesu21, pesu22].each(&:call) }

       it 'theorem is done' do
         expect(theorem.state).to eq('done')
       end
     end

     context 'last failed, others done' do
       let(:pesu11) { ProofEvaluationStateUpdater.new(proof_attempt1, :processing) }
       let(:pesu12) { ProofEvaluationStateUpdater.new(proof_attempt1, :done) }
       let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, :processing) }
       let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, :failed) }
       before { [pesu11, pesu12, pesu21, pesu22].each(&:call) }

       it 'theorem is done' do
         expect(theorem.state).to eq('done')
       end
     end

     context 'all failed' do
       let(:pesu1) { ProofEvaluationStateUpdater.new(proof_attempt1, :failed) }
       let(:pesu2) { ProofEvaluationStateUpdater.new(proof_attempt2, :failed) }
       before { [pesu1, pesu2].each(&:call) }

       it 'theorem is failed' do
         expect(theorem.state).to eq('failed')
       end

       it 'theorem contains numbers of failed proof attempts' do
         expect(theorem.last_error).
           to match(/#{[proof_attempt1, proof_attempt2].map(&:number).join(', ')}/)
       end
     end
   end
 end
