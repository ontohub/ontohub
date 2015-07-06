require 'spec_helper'

describe DistributedOntology do
  context 'associations' do
    it { expect(subject).to have_many(:children) }
  end
end
