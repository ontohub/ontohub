require 'test_helper'

class OntologyVersionTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :user
    should belong_to :ontology
  end

  context 'Parsing' do
    setup do
      OntologyVersion.any_instance.expects(:parse_async).once
      @ontology_version = Factory :ontology_version
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

    should 'raise no exception if called with remote uri' do
      assert_nothing_raised do
        @ontology_version.remote_raw_file_url = 'http://colore.googlecode.com/svn/trunk/ontologies/arithmetic/robinson_arithmetic.clif'
        @ontology_version.save!
        @ontology_version.parse
      end
    end

    should 'raise exception if called with unsupported remote file' do
      assert_raise Hets::HetsError do
        @ontology_version.remote_raw_file_url = 'http://colore.googlecode.com/svn/trunk/ontologies/algebra/module.clif'
        @ontology_version.save!
        @ontology_version.parse
      end
    end
  end
end
