require 'spec_helper'

describe Ontology do

  let(:user) { create :user }
  setup_hets

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

        expect(repository.path_exists?(file)).to be(true)
        ontology.destroy_with_parent(user)
        expect(repository.path_exists?(file)).to be(false)
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

  context 'when parsing a non-ontology-file', :needs_hets do
    let(:repository) { create :repository }
    let(:version) { add_fixture_file(repository, 'xml/catalog-v001.xml') }

    it 'no ontology should exist' do
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
  end

  context 'when parsing', :needs_hets do
    context 'a distributed ontology' do
      let(:user) { create :user }
      let(:repository) { create :repository, user: user }

      before do
        stub_hets_for(fixture_file('partial_order'))
      end

      it 'should have logic DOL' do
        path = ontology_file('casl/partial_order')
        version = repository.save_file(
          path,
          'partial_order.casl',
          'parsing a distributed ontology',
          user)

        expect(version.ontology.logic.name).to eq('DOL')
      end
    end
  end

  context 'when parsing an ontology which contains logic translations', :needs_hets do
    let(:repository) { create :repository }
    let(:version) { add_fixture_file(repository, 'dol/double_mapped_logic_translated_blendoid.dol') }
    let(:ontology) { version.ontology.children.find_by_name('DMLTB-TheClifOne') }

    context 'the logically translated ontology' do

      before do
        stub_hets_for(fixture_file('double_mapped_logic_translated_blendoid'))
      end
      it 'should contain imported sentences' do
        expect(ontology.imported_sentences).to_not be_empty
      end

      it 'should contain logic translations' do
        expect(ontology.contains_logic_translations?).to be(true)
      end

      it 'should have an ontology-version' do
        expect(ontology.ontology_version).to_not be_nil
      end

    end

  end

  # context 'when parsing an ontology which is referenced by another ontology', :needs_hets do
  #   let(:repository) { create :repository }
  #   let(:presentation) do
  #     referenced_ontology = nil
  #     ontology = define_ontology('Foo') do
  #       this = prefix('ontohub')
  #       imports define('Bar', as: :referenced_ontology) do
  #         prefix('other_ontohub').class('SomeBar')
  #       end
  #       this.class('Bar').sub_class_of this.class('Foo')
  #     end
  #   end
  #   let(:referenced_presentation) { presentation.referenced_ontology }
  #   let(:version) { version_for_file(repository, presentation.file.path) }
  #   let(:ontology) { version.ontology.reload }

  #   before do
  #     ExternalRepository.stub(:download_iri) do |external_iri|
  #       absolute_path = external_iri.sub('file://', '')
  #       dir = Pathname.new('/tmp/reference_ontologies/').
  #         join(ExternalRepository.determine_path(external_iri, :dirpath))
  #       ExternalRepository.send(:ensure_path_existence, dir)
  #       filepath = dir.join(ExternalRepository.send(:determine_basename, external_iri))
  #       FileUtils.cp(absolute_path, filepath)
  #       filepath
  #     end
  #     version
  #     ExternalRepository.unstub(:download_iri)
  #   end

  #   let(:referenced_ontology) do
  #     name = File.basename(referenced_presentation.name, '.owl')
  #     Ontology.where("name LIKE '#{name}%'").first!
  #   end

  #   it 'should import an ontology with that name' do
  #     expect(ontology.direct_imported_ontologies).to include(referenced_ontology)
  #   end

  #   it 'should have an ontology-version' do
  #     expect(ontology.ontology_version).to_not be_nil
  #   end

  #   it 'should have a referenced ontology with an ontology-version' do
  #     expect(referenced_ontology.ontology_version).to_not be_nil
  #   end
  # end

  context 'Import single Ontology' do
    let(:user) { create :user }
    let(:ontology) { create :single_ontology }

    before do
      parse_this(user, ontology, fixture_file('test1'))
    end

    it 'should save the logic' do
      expect(ontology.logic.try(:name)).to eq('CASL')
    end

    context 'entity count' do
      it 'should be correct' do
        expect(ontology.entities.count).to eq(2)
      end

      it 'should be reflected in the corresponding field' do
        expect(ontology.entities_count).to eq(ontology.entities.count)
      end
    end

    context 'sentence count' do
      it 'should be correct' do
        expect(ontology.sentences.count).to eq(1)
      end

      it 'should be reflected in the corresponding field' do
        expect(ontology.sentences_count).to eq(ontology.sentences.count)
      end
    end
  end

  context 'Import distributed Ontology' do
    let(:user) { create :user }
    let(:ontology) { create :distributed_ontology }

    before do
      parse_this(user, ontology, fixture_file('test2'))
    end

    it 'should create all single ontologies' do
      expect(SingleOntology.count).to eq(4)
    end

    it 'should have all children ontologies' do
      expect(ontology.children.count).to eq(4)
    end

    it 'should have the correct link count' do
      expect(ontology.links.count).to eq(3)
    end

    it 'should have the DOL-logic assigned to the logic-field' do
      expect(ontology.logic.try(:name)).to eq('DOL')
    end

    it 'should have no entities' do
      expect(ontology.entities.count).to eq(0)
    end

    it 'should have no sentences' do
      expect(ontology.sentences.count).to eq(0)
    end

    context 'first child ontology' do
      let(:child) { ontology.children.where(name: 'sp__E1').first }

      it 'should have entities' do
        expect(child.entities.count).to eq(2)
      end

      it 'should have one sentence' do
        expect(child.sentences.count).to eq(1)
      end
    end

    context 'all child ontologies' do
      it 'should have the same state as the parent' do
        ontology.children.each do |child|
          expect(child.state).to eq(ontology.state)
        end
      end
    end

  end

  context 'Import another distributed Ontology' do
    let(:user) { create :user }
    let(:ontology) { create :distributed_ontology }
    let(:combined) { ontology.children.where(name: 'VAlignedOntology').first }

    before do
      parse_this(user, ontology, fixture_file('align'))
    end

    it 'should create single ontologies' do
      assert_equal 4, SingleOntology.count
      expect(SingleOntology.count).to eq(4)
    end

    it 'should create a combined ontology' do
      expect(combined).to_not be_nil
    end

    context 'kinds' do
      let(:kinds) { combined.entities.map(&:kind) }

      it 'should be assigned to symbols of the combined ontology' do
        expect(kinds).to_not include('Undefined')
      end
    end

  end

  context 'Import Ontology with an error occurring while parsing' do
    let(:user) { create :user }
    let(:ontology) { create :single_ontology }
    let(:error_text) { 'An error occurred' }

    before do
      # Stub ontology_end because this is always run after the iri
      # has been locked by the ConcurrencyBalancer.
      allow_any_instance_of(Hets::NodeEvaluator).
        to receive(:ontology_end).and_raise(error_text)
    end

    it 'should propagate the error' do
      expect { parse_this(user, ontology, fixture_file('test1')) }.
        to raise_error(Exception, error_text)
    end

    it 'should be possible to parse it again (no AlreadyProcessingError)' do
      begin
        parse_this(user, ontology, fixture_file('test1'))
      rescue Exception => e
        allow_any_instance_of(Hets::NodeEvaluator).
          to receive(:ontology_end).and_call_original

        expect { parse_this(user, ontology, fixture_file('test1')) }.
          not_to raise_error
      end
    end
  end

end
