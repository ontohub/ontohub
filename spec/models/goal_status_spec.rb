require 'spec_helper'

describe GoalStatus do
  context 'Associations' do
    it { should belong_to(:proof_status) }
  end

  context 'Validations' do
    %w(open failed inconsistent disproven proven).each do |val|
      it { should allow_value(val).for :status }
    end

    [nil, '',' ', 'foo'].each do |val|
      it { should_not allow_value(val).for :status }
    end

    context 'failure_reason present' do
      context 'status: failed' do
        let(:goal_status) do
          GoalStatus.new(status: 'failed', failure_reason: 'reason')
        end
        it 'be valid' do
          expect(goal_status).to be_valid
        end
      end

      %w(open inconsistent disproven proven).each do |status|
        context "status: #{status}" do
          let(:goal_status) do
            GoalStatus.new(status: status, failure_reason: 'reason')
          end
          it 'be invalid' do
            expect(goal_status).to be_invalid
          end
        end
      end
    end

    context 'failure_reason missing' do
      context 'status: failed' do
        let(:goal_status) do
          GoalStatus.new(status: 'failed', failure_reason: nil)
        end
        it 'be invalid' do
          expect(goal_status).to be_invalid
        end
      end

      %w(open inconsistent disproven proven).each do |status|
        context "status: #{status}" do
        let(:goal_status) do
          GoalStatus.new(status: status, failure_reason: nil)
        end
          it 'be valid' do
            expect(goal_status).to be_valid
          end
        end
      end
    end
  end
end
