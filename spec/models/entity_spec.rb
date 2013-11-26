require 'spec_helper'

describe Entity do

  it { should have_db_column('description').of_type(:text) }

  it { should belong_to(:ontology) }

  context 'when importing an ontology' do
    let(:ontology) { create :ontology }
    let(:user) { create :user }
    let(:xml_path) { Rails.root + 'test/fixtures/ontologies/xml/' + 'pizza.xml' }

    before do
      ontology.import_xml_from_file xml_path, nil, user
    end

    it 'should have the correct number of described entitites' do
      described_entities = ontology.entities.
        where('description IS NOT NULL')
      described_entities.size.should be_equal(96)
    end

  end

end
