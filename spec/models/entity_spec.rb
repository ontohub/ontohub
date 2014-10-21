require 'spec_helper'

describe Entity do

  context 'Migrations and Associations' do
    columns = {
      ontology_id: :integer,
      comments_count: :integer,
      kind: :string,
      range: :string,
      name: :text,
      display_name: :text,
      label: :text,
      iri: :text,
      text: :text,
      comment: :text,
    }

    columns.each_pair do |column, column_type|
      it { should have_db_column(column).of_type(column_type) }
    end

    it { should have_db_index([:ontology_id, :id]).unique(true) }
    it { should have_db_index([:ontology_id, :text]).unique(true) }
    it { should have_db_index([:ontology_id, :kind]) }

    it { should belong_to(:ontology) }
    it { should have_and_belong_to_many :sentences }
  end

  context 'when importing an ontology' do
    let(:ontology) { create :ontology }
    let(:user) { create :user }

    before do
      parse_this(user, ontology, hets_out_file('pizza'))
    end

    it 'should have the correct number of described entities' do
      labeled_entities = ontology.entities.
        where('label IS NOT NULL')
      commented_entities = ontology.entities.
        where('comment IS NOT NULL')
      described_entities_count = labeled_entities.size + commented_entities.size
      described_entities_count.should eq(115)
    end

  end

  context 'OntologyInstance' do
    let(:ontology) { create :single_ontology }

    context 'creating CommonLogic Entities' do
      let(:entity_hash) do
        {
          'name' => 'nat',
          'range' => '28.9',
          'kind' =>  'sort',
          'text' => 'nat'
        }
      end

      before do
        ontology.entities.update_or_create_from_hash(entity_hash)
      end

      context 'attributes' do
        let(:entity) { ontology.entities.first }

        %w(name range kind text).each do |attr|
          it "should be #{attr}" do
            expect(entity.send(attr)).to eq(entity_hash[attr])
          end
        end

        it 'should have display_name' do
          expect(entity.display_name).to eq(entity_hash['name'])
        end

        it 'should have iri set to nil' do
          expect(entity.iri).to be_nil
        end
      end
    end

    context 'When creating OWL2 Entities' do
      context 'with fragment in URI' do
        let(:entity) { create :entity_owl2 }

        it 'should have an iri'  do
          expect(entity.iri).to match(%r{^http://example.com/resource#\d+$})
        end

        it 'should have fragment as the display_name attribute'  do
          fragment = entity.iri.match(/#(\d+)$/)[1]
          expect(entity.display_name).to eq(fragment)
        end
      end

      context 'without fragment in URI, the display_name attribute' do
        let(:entity_hash) do
          {
            'text' => 'Class <http://example.com/resource>',
            'name' => '<http://example.com/resource>'
          }
        end
        let(:entity) { ontology.entities.first }

        before do
          ontology.entities.update_or_create_from_hash(entity_hash)
        end

        it 'should be the last path segment' do
          expect(entity.display_name).to eq('resource')
        end
      end
    end

    context 'When creating hypothetical entity' do
      context 'where text contains name but name does not match an IRI' do
        let(:entity_hash) do
          {
            'text' => 'sort s <http://example.com/some_resource>',
            'name' => 's'
          }
        end
        let(:entity) { ontology.entities.first }

        before do
          ontology.entities.update_or_create_from_hash(entity_hash)
        end

        it 'should have display_name not set to nil' do
          expect(entity.display_name).to_not be_nil
        end

        it 'should have the iri set to nil' do
          expect(entity.iri).to be_nil
        end
      end
    end
  end

end
