require 'spec_helper'

describe ProofTree do
  context 'Associations' do
    it { should belong_to(:proof_status) }
  end

  it { should strip_attribute :tree }
end
