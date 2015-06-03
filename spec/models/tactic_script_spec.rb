require 'spec_helper'

describe TacticScript do
  context 'Associations' do
    it { should belong_to(:proof_attempt) }
    it { should have_many(:extra_options) }
  end
end
