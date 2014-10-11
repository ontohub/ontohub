require 'spec_helper'

# Tests a triple store
#
# Original author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
describe TripleStore do
  context 'Language population' do
    context 'Empty Triple List:' do
      let(:store) { TripleStore.new [] }
      let(:languageReader) { LanguagePopulation.new store }

      it "make empty list" do
        expect(languageReader.list).to be_empty
      end
    end

    context 'File Load:' do
      let(:type) { 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' }
      let(:label) { 'http://www.w3.org/2000/01/rdf-schema#label' }
      let(:comment) { 'http://www.w3.org/2000/01/rdf-schema#comment' }
      let(:defined) { 'http://www.w3.org/2000/01/rdf-schema#isDefinedBy' }
      let(:language_type) { 'http://purl.net/dol/1.0/rdf#OntologyLanguage' }
      let(:language) { 'http://ontohub.org/CommonLanguage' }
      let(:language_defined_by) { 'http://ontohub.org/CommonLanguage.rdf' }
      let(:language_name) { 'Common Language' }
      let(:language_description) { 'A language with all operators' }
      let(:store) do
        TripleStore.new [
          [language, type, language_type],
          [language, label, language_name],
          [language, comment, language_description],
          [language, defined, language_defined_by]
        ]
      end
      let(:languageReader) { LanguagePopulation.new store }
      let(:list) { languageReader.list }
      let(:language_from_list) { list.first }

      context "make one-element list" do
        it 'have a singleton list' do
          expect(list.size).to eq(1)
        end

        it 'have correct IRI' do
          expect(language_from_list.iri).to eq(language)
        end

        it 'have correct name' do
          expect(language_from_list.name).to eq(language_name)
        end

        it 'have correct description' do
          expect(language_from_list.description).to eq(language_description)
        end

        it 'have correct defined_by' do
          expect(language_from_list.defined_by).to eq(language_defined_by)
        end
      end
    end
  end

  context 'Logic population' do
    context 'Empty Triple List:' do
      let(:store) { TripleStore.new [] }
      let(:logicReader) { LogicPopulation.new store }

      it "make empty list" do
        expect(logicReader.list).to be_empty
      end
    end

    context 'File Load:' do
      let(:type) { 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' }
      let(:label) { 'http://www.w3.org/2000/01/rdf-schema#label' }
      let(:comment) { 'http://www.w3.org/2000/01/rdf-schema#comment' }
      let(:defined) { 'http://www.w3.org/2000/01/rdf-schema#isDefinedBy' }
      let(:logicType) { 'http://purl.net/dol/1.0/rdf#Logic' }
      let(:logic) { 'http://ontohub.org/CommonLogic' }
      let(:logic_defined_by) { 'http://ontohub.org/CommonLogic.rdf' }
      let(:logic_name) { 'Common Logic' }
      let(:logic_description) { 'A logic with all operators' }
      let(:store) do
        TripleStore.new [
          [logic, type, logicType],
          [logic, label, logic_name],
          [logic, comment, logic_description],
          [logic, defined, logic_defined_by]
        ]
      end
      let(:logicReader) { LogicPopulation.new store }
      let(:list) { logicReader.list }
      let(:logic_from_list) { list.first }

      context "make one-element list" do
        it 'have a singleton list' do
          expect(list.size).to eq(1)
        end

        it 'have correct IRI' do
          expect(logic_from_list.iri).to eq(logic)
        end

        it 'have correct name' do
          expect(logic_from_list.name).to eq(logic_name)
        end

        it 'have correct description' do
          expect(logic_from_list.description).to eq(logic_description)
        end

        it 'have correct defined_by' do
          expect(logic_from_list.defined_by).to eq(logic_defined_by)
        end
      end
    end
  end
end
