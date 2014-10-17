require 'spec_helper'

describe DistributedOntology do
  context 'associations' do
    it { should have_many(:children) }
  end

  context 'distributed ontology instance' do
    let(:ontology) do
      create :distributed_ontology, iri: 'http://example.com/foo'
    end

    it 'generate sub iri' do
      expect(ontology.iri_for_child('bar')).to eq('http://example.com/foo?bar')
    end

    it 'generate sub iri that already is an iri' do
      expect(ontology.iri_for_child('http://example.com/dummy')).
        to eq('http://example.com/dummy')
    end
  end
end
