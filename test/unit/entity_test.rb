require 'test_helper'

class EntityTest < ActiveSupport::TestCase
  
  %w( ontology_version_id comments_count ).each do |column|
    should have_db_column(column).of_type(:integer)
  end
  
  %w( kind name uri range ).each do |column|
    should have_db_column(column).of_type(:string)
  end

  should have_db_index([:ontology_version_id, :text]).unique(true)
  should have_db_index([:ontology_version_id, :kind])
  
  should belong_to :ontology_version
  should have_and_belong_to_many :sentences

  context 'OntologyVersionInstance' do
  	setup do
  		@ontology_version = Factory :ontology_version
  	end

  	context 'creating Entities' do
  		setup do
	  		@entity_hash = {
	  			'name' => 'nat',
	  			'range' => '28.9',
	  			'kind' =>  'sort',
	  			'text' => 'nat'
	  		}

	      @ontology_version.entities.update_or_create_from_hash @entity_hash
  		end

  		context 'correct attribute' do
  			setup do
  				@entity = @ontology_version.entities.first
  			end

  			%w[name range kind text].each do |attr|
  				should "be #{attr}" do
  					assert_equal @entity_hash[attr], eval("@entity.#{attr}")
  				end
  			end
  		end
  	end
  end
end
