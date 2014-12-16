require 'spec_helper'

describe OntologyMember::Symbol do

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

    before { parse_this(user, ontology, hets_out_file('pizza')) }

    it 'should have the correct number of described symbols' do
      labeled_symbols = ontology.symbols.
        where('label IS NOT NULL')
      commented_symbols = ontology.symbols.
        where('comment IS NOT NULL')
      described_symbols_count = labeled_symbols.size + commented_symbols.size
      described_symbols_count.should eq(115)
    end

  end

  context 'OntologyInstance' do
    let(:ontology) { create :single_ontology }

    context 'creating CommonLogic Symbols' do
      let(:symbol_hash) do
        {
          'name' => 'nat',
          'range' => '28.9',
          'kind' =>  'sort',
          'text' => 'nat'
        }
      end

      before { ontology.symbols.update_or_create_from_hash(symbol_hash) }

      context 'attributes' do
        let(:symbol) { ontology.symbols.first }

        %w(name range kind text).each do |attr|
          it "should be #{attr}" do
            expect(symbol.send(attr)).to eq(symbol_hash[attr])
          end
        end

        it 'should have display_name' do
          expect(symbol.display_name).to eq(symbol_hash['name'])
        end

        it 'should have iri set to nil' do
          expect(symbol.iri).to be_nil
        end
      end
    end

    context 'When creating OWL2 Symbols' do
      context 'with fragment in URI' do
        let(:symbol) { create :symbol_owl2 }

        it 'should have an iri'  do
          expect(symbol.iri).to match(%r{^http://example.com/resource#\d+$})
        end

        it 'should have fragment as the display_name attribute'  do
          fragment = symbol.iri.match(/#(\d+)$/)[1]
          expect(symbol.display_name).to eq(fragment)
        end
      end

      context 'without fragment in URI, the display_name attribute' do
        let(:symbol_hash) do
          {
            'text' => 'Class <http://example.com/resource>',
            'name' => '<http://example.com/resource>'
          }
        end
        let(:symbol) { ontology.symbols.first }

        before { ontology.symbols.update_or_create_from_hash(symbol_hash) }

        it 'should be the last path segment' do
          expect(symbol.display_name).to eq('resource')
        end
      end
    end

    context 'When creating hypothetical symbol' do
      context 'where text contains name but name does not match an IRI' do
        let(:symbol_hash) do
          {
            'text' => 'sort s <http://example.com/some_resource>',
            'name' => 's'
          }
        end
        let(:symbol) { ontology.symbols.first }

        before { ontology.symbols.update_or_create_from_hash(symbol_hash) }

        it 'should have display_name not set to nil' do
          expect(symbol.display_name).to_not be_nil
        end

        it 'should have the iri set to nil' do
          expect(symbol.iri).to be_nil
        end
      end
    end
  end

end
