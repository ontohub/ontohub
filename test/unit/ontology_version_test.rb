require 'test_helper'

class OntologyVersionTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :user
    should belong_to :ontology
  end

  context 'Validation' do
    setup do
      @ontology_version = Factory :ontology_version
    end

    should 'have valid URI in source_uri' do
      assert_raise ActiveRecord::RecordInvalid do
        @ontology_version.source_uri = 'invalid.....//:URI'
        @ontology_version.save!
      end
    end

    should 'raise exception if source_uri and raw_file are set' do
      assert_raise ActiveRecord::RecordInvalid do
        @ontology_version.source_uri = 'gopher://host/file'
        @ontology_version.raw_file = File.open('/etc/passwd')
        @ontology_version.save!
      end
    end
  end
end
