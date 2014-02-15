require 'spec_helper'

describe Ontology do

  context 'when naming an ontology' do
    let(:ontology) { create :ontology }
    let(:dgnode_name) { "https://raw.github.com/ontohub/OOR_Ontohub_API/master/Domain_Fields_Core.owl" }

    it 'should determine a name according to our style' do
      expect(ontology.generate_name(dgnode_name)).to eq('Domain Fields Core')
    end
  end

  context 'when deleting' do
    context 'a general ontology' do
      let(:ontology) { create :ontology }
      it 'should delete the defining file as well' do
        file = ontology.path
        ontology.destroy
        expect(ontology.repository.path_exists?(file)).to be_false
      end

      it 'should be deleted' do
        param = ontology.to_param
        ontology.destroy
        expect { Ontology.find(param) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'a single ontology in a distributed ontology' do
      let(:distributed_ontology) { create :linked_distributed_ontology }
      let(:ontology) { distributed_ontology.children.first }
      it 'should delete the parent and its child ontologies as well' do
        params = distributed_ontology.children.map(&:to_param)
        params << distributed_ontology.to_param
        ontology.destroy

        params.each do |param|
          expect { Ontology.find(param) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'a distributed ontology' do
      let (:ontology) { create :distributed_ontology }
      it 'should delete the child ontologies as well' do
        params = ontology.children.map(&:to_param)
        params << ontology.to_param
        ontology.destroy

        params.each do |param|
          expect { Ontology.find(param) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'an imported ontology' do
      let(:ontology) { create :ontology }
      let(:importing) do
        onto = create :ontology
        create :link, source: onto, target: ontology, kind: 'import'

        onto
      end

      it 'should not be allowed' do
        expect { ontology.destroy }.to raise_error(Ontology::DeleteError)
      end
    end
  end

end
