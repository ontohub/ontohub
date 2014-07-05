require 'spec_helper'

describe TarjanTree do

  context 'owl classhierachy' do
      let(:ontology) { create :ontology }
      let(:user) { create :user }
      let(:xml_path) { Rails.root + 'test/fixtures/ontologies/xml/' + 'cycle.xml' }

      before do
        ontology.import_xml_from_file xml_path, nil, user
        ontology.reload
      end

      it 'should have an entity-tree' do
        ontology.entity_groups.size.should == 3
        entities = ontology.entities.where(name: ["B1","B2","B3"])
        expect(ontology.entity_groups.includes(:entities).where("entities.id" => entities).first).not_to be_nil
      end

      it 'should have an congruence node' do
        ontology.entity_groups.where("name LIKE '%☰%'")
      end

    end

end
