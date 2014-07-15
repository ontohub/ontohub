require 'test_helper'

class OntologyTest < ActiveSupport::TestCase

  should belong_to :language
  should belong_to :logic
  should belong_to :ontology_version
  should belong_to :ontology_type

  should have_many :versions
  should have_many :comments
  should have_many :sentences
  should have_many :entities

  should have_and_belong_to_many :projects

  should have_db_index(:iri).unique(true)
  should have_db_index(:state)
  should have_db_index(:language_id)
  should have_db_index(:logic_id)

  should strip_attribute :name
  should strip_attribute :iri
  should_not strip_attribute :description

  context 'Validations' do
    ['http://example.com/', 'https://example.com/', 'file://path/to/file'].each do |val|
      should allow_value(val).for :iri
    end

    should_not allow_value(nil).for :iri

    ['http://example.com/', 'https://example.com/', 'file://path/to/file', '', nil].each do |val|
      should allow_value(val).for :documentation
    end

    should_not allow_value('fooo').for :documentation
  end

  context 'ontology instance' do
    setup do
      @ontology = FactoryGirl.create :ontology
    end

    context 'with name' do
      setup do
        @name = "fooo"
        @ontology.name = @name
      end
      should 'have to_s' do
        assert_equal @name, @ontology.to_s
      end
    end

    context 'without name' do
      setup do
        @ontology.name = nil
      end
      should 'have to_s' do
        assert_equal @ontology.iri, @ontology.to_s
      end
    end
  end

  context 'checking ordering of Ontology list' do
    setup do
      Ontology::States::STATES.each do |state|
        FactoryGirl.create :ontology, state: state
      end
      @ontology_list = Ontology.list
      @done_state = "done"
    end

    should 'list done ontologies first' do
      assert_equal @done_state, @ontology_list.first.state
    end
  end

  context 'determining active version of ontology' do

    should 'be equal to current version, if there is only one' do
      @ontology_one_version = FactoryGirl.create(:ontology_version).ontology

      assert_equal @ontology_one_version.ontology_version,
        @ontology_one_version.active_version
    end

    should 'be equal to current version, if current is done' do
      @ontology_two_versions = FactoryGirl.create(:ontology_version).ontology
      FactoryGirl.create(:ontology_version, ontology: @ontology_two_versions)

      assert_equal @ontology_two_versions.ontology_version,
        @ontology_two_versions.active_version
    end

    should 'be equal to second to latest version , if current failed' do
      @ontology = FactoryGirl.create(:ontology)
      @done_version = FactoryGirl.create(:ontology_version,
                                         state: 'done',
                                         ontology: @ontology)
      @ontology.ontology_version = FactoryGirl.create(:ontology_version,
                                                      state: 'failed',
                                                      ontology: @ontology)
      @ontology.state = 'failed'
      @ontology.save
      @failed_version = @ontology.ontology_version

      assert_equal @done_version, @ontology.active_version
    end

  end

  context 'correctness of non_current_active_version? question' do

    setup do
      @admin = FactoryGirl.create(:user, admin: true)
      @user = FactoryGirl.create(:user)
      @owner = FactoryGirl.create(:user)
      @ontology = FactoryGirl.create(:ontology)
      FactoryGirl.create(:ontology_version,
                         state: 'done',
                         user: @owner,
                         ontology: @ontology)
      @ontology.ontology_version = FactoryGirl.create(:ontology_version,
                                                      state: 'failed',
                                                      user: @owner,
                                                      ontology: @ontology)
      @ontology.state = 'failed'
      @ontology.save
      @current_ontology = FactoryGirl.create(:ontology)
      @current_ontology.ontology_version = FactoryGirl.create(:ontology_version,
                                                              state: 'done',
                                                              user: @owner,
                                                              ontology: @current_ontology)
      @current_ontology.save
    end

    should "be true, iff the active version != current one according to user" do
      assert !@ontology.non_current_active_version?
      assert !@ontology.non_current_active_version?(@user)
      assert @ontology.non_current_active_version?(@admin)
      assert @ontology.non_current_active_version?(@owner)
    end

    should "be false, iff the active version == current one according to user" do
      assert !@current_ontology.non_current_active_version?
      assert !@current_ontology.non_current_active_version?(@user)
      assert !@current_ontology.non_current_active_version?(@admin)
      assert !@current_ontology.non_current_active_version?(@owner)
    end

  end

end
