require 'spec_helper'

describe Ontology do
  let(:user) { create :user }

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
        repository = ontology.repository

        repository.git.commit_file(repository.user_info(user), 'file deletion test', file, 'add file')

        expect(repository.path_exists?(file)).to be_true
        ontology.destroy_with_parent(user)
        expect(repository.path_exists?(file)).to be_false
      end

      it 'should be deleted' do
        param = ontology.to_param
        ontology.destroy_with_parent(user)
        expect { Ontology.find(param) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'a single ontology in a distributed ontology' do
      let(:distributed_ontology) { create :linked_distributed_ontology }
      let(:ontology) { distributed_ontology.children.first }
      it 'should delete the parent and its child ontologies as well' do
        params = distributed_ontology.children.map(&:to_param)
        params << distributed_ontology.to_param
        ontology.destroy_with_parent(user)

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
        ontology.destroy_with_parent(user)

        params.each do |param|
          expect { Ontology.find(param) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'an imported ontology' do
      let(:ontology) { create :ontology }

      it 'should not be allowed' do
        importing = create :ontology
        create :import_link, target: importing, source: ontology
        expect { ontology.destroy_with_parent(user) }.to raise_error(Ontology::DeleteError)
      end
    end
  end

  context 'when parsing a non-ontology-file' do
    let(:repository) { create :repository }
    let(:version) { add_fixture_file(repository, 'xml/catalog-v001.xml') }

    before do
      version.parse
    end

    it 'no ontology should exist' do
      puts repository.ontologies.inspect
      expect(repository.ontologies).to be_empty
    end

  end

  context 'when trying to get the imported ontologies' do
    let!(:ontology) { create :ontology }
    let!(:imported_ontology) do
      imported = create :single_ontology
      create :import_link, target: ontology, source: imported
      imported
    end

    it 'should fetch immediately imported ontologies' do
      expect(ontology.imported_ontologies).to include(imported_ontology)
      expect(ontology.imported_ontologies.size).to be(1)
    end

    context 'which have imports themselves' do
      let!(:imported_imported_ontology) do
        imported = create :single_ontology
        create :import_link, target: imported_ontology, source: imported
        imported
      end

      it 'should fetch all imported ontologies' do
        expect(ontology.imported_ontologies).to include(imported_ontology)
        expect(ontology.imported_ontologies).
          to include(imported_imported_ontology)
        expect(ontology.imported_ontologies.size).to be(2)
      end

    end
    
    context 'owl classhierachy' do
      let(:ontology) { create :ontology }
      let(:user) { create :user }
      let(:xml_path) { Rails.root + 'test/fixtures/ontologies/xml/' + 'pizza.xml' }

      before do
        ontology.import_xml_from_file xml_path, nil, user
        ontology.create_entity_tree
      end
      
      it 'should have an complete entity-tree' do
        ontology.size_of_entity_tree.should_not == 0
        ontology.tree_percentage.should == 100
      end 
      
    end
  end

  context 'when parsing an ontology which contains logic translations' do
    let(:repository) { create :repository }
    let(:version) { add_fixture_file(repository, 'dol/double_mapped_logic_translated_blendoid.dol') }
    let(:ontology) { version.ontology.children.find_by_name('DMLTB-TheClifOne') }

    context 'the logically translated ontology' do
      before do
        version.parse
      end

      it 'should contain imported sentences' do
        expect(ontology.imported_sentences).to_not be_empty
      end

      it 'should contain logic translations' do
        expect(ontology.contains_logic_translations?).to be_true
      end

    end

  end

end
