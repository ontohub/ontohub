require 'test_helper'

class OntologyVersionTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :ontology

  should have_db_index([:ontology_id, :number])
  should have_db_index(:user_id)
  should have_db_index(:commit_oid)
  should have_db_index(:checksum)
  
  setup do
    @user = FactoryGirl.create :user
  end

  context 'Validating OntologyVersion' do
    ['http://example.com/', 'https://example.com/'].each do |val|
      should allow_value(val).for :source_url
    end

    # [nil, '','fooo'].each do |val|
    #   should_not allow_value(val).for :source_url
    # end
  end
  
  context 'OntologyVersion' do
    setup do
      OntologyVersion.any_instance.expects(:parse_async).once
      @ontology_version = FactoryGirl.create :ontology_version
    end
    should 'have url' do
      assert_equal "http://example.com/ontologies/#{@ontology_version.ontology_id}/versions/1", @ontology_version.url
    end
  end
  
  context 'Parsing' do
    setup do
      OntologyVersion.any_instance.expects(:parse_async).once

      @ontology = FactoryGirl.create :ontology
      @version  = @ontology.save_file File.open('test/fixtures/ontologies/owl/pizza.owl'), "message", FactoryGirl.create(:user)
      @version.parse
    end

    should 'be done' do
      assert_equal 'done', @ontology.reload.state
    end
    
  end
end
