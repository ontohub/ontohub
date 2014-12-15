require 'spec_helper'

describe TarjanTree do

  context 'owl classhierachy' do
      let(:ontology) { create :ontology }
      let(:user) { create :user }

      before do
        parse_this(user, ontology, hets_out_file('cycle'))
        ontology.reload
      end

      it 'should have an symbol-tree' do
        ontology.symbol_groups.size.should == 3
        symbols = ontology.symbols.where(name: ["B1","B2","B3"])
        expect(ontology.symbol_groups.includes(:symbols).where("symbols.id" => symbols).first).not_to be_nil
      end

      it 'should have an congruence node' do
        ontology.symbol_groups.where("name LIKE '%☰%'")
      end

    end

end
