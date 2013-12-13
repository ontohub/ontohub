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
      @ontology_version = FactoryGirl.create :ontology_version
    end
    should 'have url' do
      assert_match %r(http://example\.com/repositories/#{@ontology_version.repository.path}/ontologies/\d+/versions/\d+$), @ontology_version.url
    end
  end
  
  context 'Parsing' do
    setup do
      @ontology = FactoryGirl.create :ontology

      # Clear Jobs
      Worker.jobs.clear

      assert_difference 'Worker.jobs.count' do
        @version  = @ontology.save_file File.open('test/fixtures/ontologies/owl/pizza.owl'), "message", FactoryGirl.create(:user)
      end

      # Run Job
      Worker.drain
    end

    should 'be done' do
      assert_equal 'done', @ontology.reload.state
    end

    should 'have checksum' do
      assert_match /^[a-z0-9]{40}$/, @version.reload.checksum
    end
    
  end
end
