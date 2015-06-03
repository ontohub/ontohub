require 'spec_helper'

describe OopsRequest do
  context 'associations' do
    it { should belong_to :ontology_version }
    it { should have_many :responses }
  end
end
