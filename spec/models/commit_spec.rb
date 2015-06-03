require 'spec_helper'

describe Commit do
  context 'associations' do
    %i(ontology_versions ontologies).each do |association|
      it { should have_many(association) }
    end

    it { should belong_to(:repository) }
  end
end
