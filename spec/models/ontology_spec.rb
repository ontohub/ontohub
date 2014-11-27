require 'spec_helper'

describe Ontology do
  let(:user) { create :user }
  setup_hets

  context 'associations' do
    %i(language logic ontology_version ontology_type).each do |association|
      it { should belong_to(association) }
    end

    %i(versions comments sentences entities).each do |association|
      it { should have_many(association) }
    end

    %i(projects).each do |association|
      it { should have_and_belong_to_many(association) }
    end
  end

  context 'migrations' do
    it { should have_db_index(:iri).unique(true) }
    it { should have_db_index(:state) }
    it { should have_db_index(:language_id) }
    it { should have_db_index(:logic_id) }
  end

  context 'attributes' do
    it { should strip_attribute :name }
    it { should strip_attribute :iri }
    it { should_not strip_attribute :description }
  end

  context 'Validations' do
    ['http://example.com/', 'https://example.com/', 'file://path/to/file'].
      each do |val|
      it { should allow_value(val).for :iri }
    end

    it { should_not allow_value(nil).for :iri }

    [
      'http://example.com/',
      'https://example.com/',
      'file://path/to/file',
      '',
      nil
    ].each do |val|
      it { should allow_value(val).for :documentation }
    end

    it { should_not allow_value('fooo').for :documentation }
  end

  context 'ontology instance' do
    let(:ontology) { create :ontology }

    context 'with name' do
      let(:name) { 'fooo' }

      before { ontology.name = name }

      it 'have to_s' do
        expect(ontology.to_s).to eq(name)
      end
    end

    context 'without name' do
      before { ontology.name = nil }

      it 'have to_s' do
        expect(ontology.to_s).to eq(ontology.iri)
      end
    end
  end

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
      let(:file) { ontology.path }
      let(:repository) { ontology.repository }

      before do
        repository.git.commit_file(repository.user_info(user), 'file deletion test', file, 'add file')
      end

      it 'should delete the defining file as well' do
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

      before do
        stub = ->(_u, _t, _m, &block) { block.call('0'*40) }
        allow_any_instance_of(Repository).to receive(:delete_file, &stub)
      end

      it 'should delete the parent' do
        param = distributed_ontology.to_param

        ontology.destroy_with_parent(user)
        expect { Ontology.find(param) }.
          to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'should delete all child ontologies as well' do
        params = distributed_ontology.children.map(&:to_param)

        ontology.destroy_with_parent(user)
        params.each do |param|
          expect { Ontology.find(param) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'a distributed ontology' do
      let (:ontology) { create :linked_distributed_ontology }

      before do
        stub = ->(_u, _t, _m, &block) { block.call('0'*40) }
        allow_any_instance_of(Repository).to receive(:delete_file, &stub)
      end

      it 'should delete the child ontologies as well' do
        param = ontology.to_param
        ontology.destroy_with_parent(user)

        expect { Ontology.find(param) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'should delete the child ontologies as well' do
        params = ontology.children.map(&:to_param)
        ontology.destroy_with_parent(user)

        expect { Ontology.find(params) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'an imported ontology' do
      let(:ontology) { create :ontology }

      before do
        stub = ->(_u, _t, _m, &block) { block.call('0'*40) }
        allow_any_instance_of(Repository).to receive(:delete_file, &stub)
      end

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
        stub_hets_for(hets_out_file('partial_order'))
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
        stub_hets_for(hets_out_file('double_mapped_logic_translated_blendoid'))
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
      parse_this(user, ontology, hets_out_file('test1'))
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
      parse_this(user, ontology, hets_out_file('test2'))
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
      parse_this(user, ontology, hets_out_file('align'))
    end

    it 'should create single ontologies' do
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
      expect { parse_this(user, ontology, hets_out_file('test1')) }.
        to raise_error(Exception, error_text)
    end

    it 'should be possible to parse it again (no AlreadyProcessingError)' do
      begin
        parse_this(user, ontology, hets_out_file('test1'))
      rescue Exception => e
        allow_any_instance_of(Hets::NodeEvaluator).
          to receive(:ontology_end).and_call_original

        expect { parse_this(user, ontology, hets_out_file('test1')) }.
          not_to raise_error
      end
    end
  end

  context 'Import Ontology with a theorem' do
    let(:user) { create :user }
    let(:ontology) { create :distributed_ontology }
    let(:child_with_theorem) do
      ontology.children.where(name: 'strict_partial_order').first
    end

    before do
      parse_this(user, ontology, hets_out_file('partial_order'))
    end

    context 'theorem count' do
      it 'should be correct' do
        expect(child_with_theorem.theorems.count).to eq(1)
      end

      it 'should be reflected in the corresponding field' do
        expect(child_with_theorem.theorems_count).
          to eq(child_with_theorem.theorems.count)
      end
    end
  end

  context 'checking ordering of Ontology list' do
    before do
      Ontology::States::STATES.each do |state|
        create :ontology, state: state
      end
    end
    let(:ontology_list) { Ontology.list }
    let(:done_state) { 'done' }

    it 'list done ontologies first' do
      expect(ontology_list.first.state).to eq(done_state)
    end
  end

  context 'determining active version of ontology' do
    context 'with only one version' do
      let(:ontology_one_version) do
        create(:ontology_version).ontology
      end
      it 'be equal to current version' do
        expect(ontology_one_version.active_version).
          to eq(ontology_one_version.ontology_version)
      end
    end

    context 'if current is done' do
      let(:ontology_two_versions) do
        create(:ontology_version).ontology
      end
      before do
        create(:ontology_version, ontology: ontology_two_versions)
      end

      it 'be equal to current version' do
        expect(ontology_two_versions.active_version).
          to eq(ontology_two_versions.ontology_version)
      end
    end

    context 'if current failed' do
      let!(:ontology) { create :ontology }
      let!(:done_version) do
        create :ontology_version,
          state: 'done', ontology: ontology
      end
      let!(:failed_version) do
        create(:ontology_version,
          state: 'failed', ontology: ontology)
      end

      before do
        ontology.ontology_version = failed_version
        ontology.state = 'failed'
        ontology.save
      end

      it 'be equal to second to latest version' do
        expect(ontology.active_version).to eq(done_version)
      end
    end
  end

  context 'correctness of non_current_active_version? question' do
    let!(:admin) { create(:user, admin: true) }
    let!(:user) { create(:user) }
    let!(:owner) { create(:user) }
    let!(:ontology) { create(:ontology) }
    let!(:failed_version) do
      create(:ontology_version,
        state: 'failed', user: owner, ontology: ontology)
    end

    let!(:current_ontology) { create(:ontology) }
    let!(:current_ontology_version) do
      create(:ontology_version,
        state: 'done', user: owner, ontology: current_ontology)
    end
    before do
      create(:ontology_version,
                         state: 'done',
                         user: owner,
                         ontology: ontology)
      ontology.ontology_version = failed_version
      ontology.state = 'failed'
      ontology.save
      current_ontology.ontology_version = current_ontology_version
      current_ontology.save
    end

    context 'be true, iff the active version != current one '\
      'according to user' do

      it 'not the non-current active version' do
        expect(ontology.non_current_active_version?).to be(false)
      end

      it 'not the non-current active version for the user' do
        expect(ontology.non_current_active_version?(user)).to be(false)
      end

      it 'not the non-current active version for the admin' do
        expect(ontology.non_current_active_version?(admin)).to be(true)
      end

      it 'not the non-current active version for the owner' do
        expect(ontology.non_current_active_version?(owner)).to be(true)
      end
    end

    context 'be false, iff the active version == current one '\
      'according to user' do

      it 'not the non-current active version' do
        expect(current_ontology.non_current_active_version?).to be(false)
      end

      it 'not the non-current active version for the user' do
        expect(current_ontology.non_current_active_version?(user)).to be(false)
      end

      it 'not the non-current active version for the admin' do
        expect(current_ontology.non_current_active_version?(admin)).to be(false)
      end

      it 'not the non-current active version for the owner' do
        expect(current_ontology.non_current_active_version?(owner)).to be(false)
      end
    end
  end
end
