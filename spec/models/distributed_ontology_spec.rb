require 'spec_helper'

describe DistributedOntology do
  context 'associations' do
    it { should have_many(:children) }
  end
end
