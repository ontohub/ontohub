require 'spec_helper'

describe TarjanTree do

  context 'owl classhierachy' do
      let(:ontology) { create :ontology }
      let(:user) { create :user }

      before do
        parse_this(user, ontology, hets_out_file('cycle'))
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
