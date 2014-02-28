require 'spec_helper'

describe Ontology do

  context 'when naming an ontology' do
    let(:ontology) { create :ontology }
    let(:dgnode_name) { "https://raw.github.com/ontohub/OOR_Ontohub_API/master/Domain_Fields_Core.owl" }

    it 'should determine a name according to our style' do
      expect(ontology.generate_name(dgnode_name)).to eq('Domain Fields Core')
    end
  end

  context 'when trying to get the imported ontologies' do
    let!(:ontology) { create :ontology }
    let!(:imported_ontology) do
      imported = create :single_ontology
      create :import_link, source: ontology, target: imported
      imported
    end

    it 'should fetch immediately imported ontologies' do
      expect(ontology.imported_ontologies).to include(imported_ontology)
      expect(ontology.imported_ontologies.size).to be(1)
    end

    context 'which have imports themselves' do
      let!(:imported_imported_ontology) do
        imported = create :single_ontology
        create :import_link, source: imported_ontology, target: imported
        imported
      end

      it 'should fetch all imported ontologies' do
        expect(ontology.imported_ontologies).to include(imported_ontology)
        expect(ontology.imported_ontologies).
          to include(imported_imported_ontology)
        expect(ontology.imported_ontologies.size).to be(2)
      end

    end

  end

end
