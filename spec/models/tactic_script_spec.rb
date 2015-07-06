require 'spec_helper'

describe TacticScript do
  context 'Associations' do
    it { expect(subject).to belong_to(:proof_attempt) }
    it { expect(subject).to have_many(:extra_options) }
  end
end
