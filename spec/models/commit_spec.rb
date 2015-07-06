require 'spec_helper'

describe Commit do
  context 'associations' do
    %i(ontology_versions ontologies).each do |association|
      it { expect(subject).to have_many(association) }
    end

    it { expect(subject).to belong_to(:repository) }
  end
end
