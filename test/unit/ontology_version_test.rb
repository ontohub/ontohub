require 'test_helper'

class OntologyVersionTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :ontology

  should have_db_index([:ontology_id, :number])
  should have_db_index(:user_id)
  should have_db_index(:previous_version_id)
  should have_db_index(:checksum)
  
  setup do
    @user = FactoryGirl.create :user
  end

  context 'Validating OntologyVersion' do
    ['http://example.com/', 'https://example.com/'].each do |val|
      should allow_value(val).for :source_url
    end

    [nil, '','fooo'].each do |val|
      should_not allow_value(val).for :source_url
    end
  end
  
  context 'Creating OntologyVersion' do
    setup do
      @ontology = FactoryGirl.create :ontology
      @version  = @ontology.versions.build
    end
    
    context 'without addional attributes' do
      should 'be invalid' do
        assert @version.invalid?
      end
    end
    
    context 'with invalid source_url' do
      setup do
        @version.source_url = 'invalid'
      end
      should 'be invalid' do
        assert @version.invalid?
      end
    end
    
    context 'with valid remote_raw_file_url' do
      setup do
        @version.remote_raw_file_url = 'http://trac.informatik.uni-bremen.de:8080/hets/export/16726/trunk/OWL2/tests/family.owl'
      end
      should 'be valid' do
        assert @version.valid?
      end
    end
    
    context 'with valid raw_file' do
      setup do
        @version.raw_file = File.open("#{Rails.root}/test/fixtures/ontologies/owl/pizza.owl")
      end
      should 'be invalid' do
        assert @version.valid?
      end
    end
    
    context 'with valid source_url' do
      setup do
        @version.source_url = 'http://example.com/fooo'
      end
      should 'be valid' do
        assert @version.valid?
      end
    end
  end
  
  context 'OntologyVersion' do
    setup do
      @ontology_version = FactoryGirl.create :ontology_version
    end
    should 'have url' do
      assert_equal "http://example.com/ontologies/#{@ontology_version.ontology_id}/versions/1", @ontology_version.url
    end
  end
  
  context 'Parsing' do
    setup do
      OntologyVersion.any_instance.expects(:parse_async).once
      @ontology_version = FactoryGirl.build :ontology_version
      @pizza_owl = 'test/fixtures/ontologies/owl/pizza.owl'
    end

    should 'raise no exception' do
      assert_nothing_raised do
        @ontology_version.raw_file = File.open(@pizza_owl)
        @ontology_version.save!
        @ontology_version.parse
      end
    end

    should 'raise exception if called without setting raw_file' do
      assert_raise ArgumentError do
        @ontology_version.parse
      end
    end

    should 'raise no exception if called with remote iri' do
      assert_nothing_raised do
        @ontology_version.remote_raw_file_url = 'http://colore.googlecode.com/svn-history/r679/trunk/ontologies/arithmetic/robinson_arithmetic.clif'
        @ontology_version.save!
        @ontology_version.parse
      end
    end

    should 'raise exception if called with unsupported remote file' do
      assert_raise Hets::HetsError do
        @ontology_version.remote_raw_file_url = 'http://colore.googlecode.com/svn-history/r679/trunk/ontologies/algebra/module.clif'
        @ontology_version.save!
        @ontology_version.parse
      end
    end
  end
end
