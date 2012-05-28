require 'test_helper'

class EntityTest < ActiveSupport::TestCase
  
  %w( ontology_id comments_count ).each do |column|
    should have_db_column(:comments_count).of_type(:integer)
  end
  
  %w( kind name uri range ).each do |column|
    should have_db_column(column).of_type(:string)
  end

  should have_db_index([:ontology_id, :text]).unique(true)
  should have_db_index([:ontology_id, :kind])
  
  should belong_to :ontology
  should have_and_belong_to_many :sentences

  context 'OntologyInstance' do
  	setup do
  		@ontology = Factory :ontology
  	end

  	context 'creating Entities' do
  		setup do
	  		@entity_hash = {
	  			'name' => 'nat',
	  			'range' => '28.9',
	  			'kind' =>  'sort',
	  			'text' => 'nat'
	  		}

	      @ontology.entities.update_or_create_from_hash @entity_hash
  		end

  		context 'correct attribute' do
  			setup do
  				@entity = @ontology.entities.first
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
