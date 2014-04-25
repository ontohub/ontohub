require 'spec_helper'

describe EntityMapping do

  context 'when importing an ontology' do
    let(:repository) { create :repository }
    let(:version) { add_fixture_file(repository, 'dol/simple_mapping.dol') }
    let(:dist_ontology) { version.ontology }

    context 'which has mapped symbols' do
      let(:ontology) { dist_ontology.children.find_by_name('test') }

      before do
        Sidekiq::Testing.inline! do
          version.async_parse
        end
      end

      it 'should not contain the mapped symbol' do
        expect(ontology.entities.find_by_name('Human')).to be_nil
      end

    end
  end

end

