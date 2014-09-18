require 'spec_helper'

describe EntityMapping do

  context 'when importing an ontology', :needs_hets do
    let(:repository) { create :repository }
    let(:version) { add_fixture_file(repository, 'dol/simple_mapping') }
    let(:dist_ontology) { version.ontology }

    before do
      stub_hets_for(hets_out_file('simple_mapping'))
    end

    context 'which has mapped symbols' do
      let(:ontology) { dist_ontology.children.find_by_name('test') }

      it 'should not contain the mapped symbol' do
        expect(ontology.entities.find_by_name('Human')).to be_nil
      end

    end
  end

end

