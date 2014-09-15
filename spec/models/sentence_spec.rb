require 'spec_helper'

describe Sentence do

  context 'Migrations' do
    it 'should have the correct integer columns' do
      %w( ontology_id comments_count ).each do |column|
        have_db_column(column).of_type(:integer)
      end
    end

    it 'should have the correct string columns' do
      %w( range ).each do |column|
        have_db_column(column).of_type(:string)
      end
    end

    it 'should have the correct text columns' do
      %w( name text display_text ).each do |column|
        have_db_column(column).of_type(:text)
      end
    end

    it { have_db_index([:ontology_id, :id]).unique(true) }
    it { have_db_index([:ontology_id, :name]).unique(true) }
  end

  context 'Associations' do
    it { belong_to :ontology }
    it { have_and_belong_to_many :entities }
  end

  context 'OntologyInstance' do

    let(:ontology) { create :single_ontology }

    context 'creating Sentences' do
      let(:sentence_hash) do
        {
          'name' => '... (if exists)',
          'range' => 'Examples/Reichel:40.9'
        }
      end

      before do
        ontology.sentences.update_or_create_from_hash sentence_hash
      end

      context 'correct attribute' do
        let(:sentence) { ontology.sentences.first }

        %i[name range].each do |attr|
          it "should be #{attr}" do
            expect(sentence.send(attr)).to eq(sentence_hash[attr.to_s])
          end
        end
      end

    end

    context 'OWL2 sentences' do

      let(:ontology) { create :single_ontology }
      let(:user) { create :user }
      let(:sentence) { ontology.sentences.first }


      before do
        parse_this(user, ontology, fixture_file('generations'))
      end

      it 'should have display_text set' do
        expect(sentence.display_text).to_not be_nil
      end

      it "should not contain entities' iris" do
        sentence.entities.each do |entity|
          expect(sentence.display_text).to_not include(entity.iri)
        end
      end
    end

  end

  context 'extracted names' do
    let(:sentence) { create :sentence, :of_meta_ontology }
    let(:class_names) { sentence.hierarchical_class_names }
    let(:name1) { class_names.first }
    let(:name2) { class_names.last }

    it "should match iris\' fragments" do
      expect(name1).to eq('https://github.com/ontohub/OOR_Ontohub_API/blob/master/Domain_fields.owl#Accounting_and_taxation')
      expect(name2).to eq('https://github.com/ontohub/OOR_Ontohub_API/blob/master/Domain_fields.owl#Business_and_administration')
    end
  end

end
