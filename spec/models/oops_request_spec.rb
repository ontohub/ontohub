require 'spec_helper'

describe OopsRequest do
  context 'associations' do
    it { expect(subject).to belong_to :ontology_version }
    it { expect(subject).to have_many :responses }
  end
end
