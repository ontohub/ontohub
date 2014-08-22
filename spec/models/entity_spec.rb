require 'spec_helper'

describe Entity do

  it { should have_db_column('label').of_type(:text) }
  it { should have_db_column('comment').of_type(:text) }

  it { should belong_to(:ontology) }

  context 'when importing an ontology' do
    let(:ontology) { create :ontology }
    let(:user) { create :user }
    let(:xml_path) { Rails.root + 'test/fixtures/ontologies/xml/' + 'pizza.xml' }

    before do
      parse_this(user, ontology, xml_path, nil)
    end

    it 'should have the correct number of described entities' do
      labeled_entities = ontology.entities.
        where('label IS NOT NULL')
      commented_entities = ontology.entities.
        where('comment IS NOT NULL')
      described_entities_count = labeled_entities.size + commented_entities.size
      described_entities_count.should be(115)
    end

  end

end
