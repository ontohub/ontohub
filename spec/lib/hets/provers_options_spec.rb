require 'spec_helper'

describe Hets::ProversOptions do
  let(:parent_ontology) { create :linked_distributed_ontology }
  let(:child_ontology) { parent_ontology.children.first }

  context 'with strings' do
    let(:options) { {node: child_ontology.name} }
    let(:provers_options) { Hets::ProversOptions.new(options) }

    it 'does not change the options' do
      expect(provers_options.options).to eq(options)
    end
  end

  context 'with general objects' do
    let(:options) { {ontology: child_ontology} }
    let(:provers_options) { Hets::ProversOptions.new(options) }

    it "removes the key 'ontology'" do
      expect(provers_options.options.has_key?(:ontology)).to be(false)
    end

    it 'sets :node to the ontology name' do
      expect(provers_options.options[:node]).to eq(child_ontology.name)
    end
  end

  context 'using the parent ontology' do
    let(:options) { {ontology: parent_ontology} }
    let(:provers_options) { Hets::ProversOptions.new(options) }

    it 'it does not set :node' do
      expect(provers_options.options.has_key?(:node)).to be(false)
    end

    it "removes the key 'ontology'" do
      expect(provers_options.options.has_key?(:ontology)).to be(false)
    end
  end
end
