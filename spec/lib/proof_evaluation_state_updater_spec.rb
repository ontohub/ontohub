 require 'spec_helper'

 describe ProofEvaluationStateUpdater do
   context 'single proof attempt from pending state' do
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

   context 'many proof attempts all from pending state' do
     # All examples here simulate the state machine of the state-changes.
     # We only check the following state changes
     # pending -> processing
     # processing -> failed, no_result, done
     # failed -> pending
     # That's why we call the ProofEvaluationStateUpdater many times on the same
     # ProofAttempt in the setup.
     let!(:proof_attempt1) { create :proof_attempt, state: 'pending' }
     let(:theorem) { proof_attempt1.theorem }
     let!(:proof_attempt2) { create :proof_attempt, theorem: theorem, state: 'pending' }

     context 'first pending' do
       %w(pending processing done).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it "theorem is #{state}" do
             expect(theorem.state).to eq(state)
           end
         end
       end

       %w(failed no_result).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it 'theorem is pending' do
             expect(theorem.state).to eq('pending')
           end
         end
       end
     end

     context 'first processing' do
       let(:pesu1) { ProofEvaluationStateUpdater.new(proof_attempt1, 'processing') }
       before { pesu1.call }

       %w(processing done).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it "theorem is #{state}" do
             expect(theorem.state).to eq(state)
           end
         end
       end

       %w(failed no_result pending).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it 'theorem is processing' do
             expect(theorem.state).to eq('processing')
           end
         end
       end
     end

     context 'first done' do
       let(:pesu11) { ProofEvaluationStateUpdater.new(proof_attempt1, 'processing') }
       let(:pesu12) { ProofEvaluationStateUpdater.new(proof_attempt1, 'done') }
       before { [pesu11, pesu12].each(&:call) }

       %w(done).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it "theorem is #{state}" do
             expect(theorem.state).to eq(state)
           end
         end
       end

       %w(failed no_result pending processing).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it 'theorem is done' do
             expect(theorem.state).to eq('done')
           end
         end
       end
     end

     context 'first failed' do
       let(:pesu11) { ProofEvaluationStateUpdater.new(proof_attempt1, 'processing') }
       let(:pesu12) { ProofEvaluationStateUpdater.new(proof_attempt1, 'failed') }
       before { [pesu11, pesu12].each(&:call) }

       %w(no_result pending processing done).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it "theorem is #{state}" do
             expect(theorem.state).to eq(state)
           end
         end
       end

       %w(failed).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it 'theorem is failed' do
             expect(theorem.state).to eq('failed')
           end
         end
       end
     end

     context 'first no_result' do
       let(:pesu11) { ProofEvaluationStateUpdater.new(proof_attempt1, 'processing') }
       let(:pesu12) { ProofEvaluationStateUpdater.new(proof_attempt1, 'no_result') }
       before { [pesu11, pesu12].each(&:call) }

       %w(no_result pending processing done).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it "theorem is #{state}" do
             expect(theorem.state).to eq(state)
           end
         end
       end

       %w(failed).each do |state|
         context "last #{state}" do
           let(:pesu21) { ProofEvaluationStateUpdater.new(proof_attempt2, 'processing') }
           let(:pesu22) { ProofEvaluationStateUpdater.new(proof_attempt2, state) }
           before { [pesu21, pesu22].each(&:call) }

           it 'theorem is no_result' do
             expect(theorem.state).to eq('no_result')
           end
         end
       end
     end
   end
 end
