require 'spec_helper'

describe TacticScript do
  context 'Associations' do
    it { should belong_to(:proof_attempt) }
    it { should have_many(:extra_options) }
  end

  let(:tactic_script) { create :tactic_script, :with_extra_options }
  subject { tactic_script }

  context 'to_s' do
    it 'contains the time_limit' do
      expect(subject.to_s).to include(subject.time_limit.to_s)
    end

    it 'contains the extra options' do
      subject.extra_options.each do |extra_option|
        expect(subject.to_s).to include(extra_option.to_s)
      end
    end
  end
end
