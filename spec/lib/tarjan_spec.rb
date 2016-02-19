require 'spec_helper'

describe TarjanTree do

  context 'owl classhierachy' do
      let(:ontology) { create :ontology }
      let(:user) { create :user }

      before do
        parse_ontology(user,
                       ontology,
                       'owl/cycle_with_class_without_inheritance.owl',
                      )
        ontology.reload
      end

      it 'should have an symbol-tree' do
        expect(ontology.symbol_groups.size).to be(4)
        symbols = ontology.symbols.where(name: ["B1","B2","B3"])
        expect(ontology.symbol_groups.includes(:symbols).where("symbols.id" => symbols).first).not_to be(nil)
      end

      it 'should have an congruence node' do
        expect(ontology.symbol_groups.where("name LIKE '%☰%'")).not_to be_empty
      end

      it 'should have an node without children and parent' do
        symbol_group = ontology.symbol_groups.where(name: "D").first
        expect(symbol_group).not_to be(nil)
        expect(symbol_group.children).to be_empty
        expect(symbol_group.ancestors).to be_empty
      end

    end

end
