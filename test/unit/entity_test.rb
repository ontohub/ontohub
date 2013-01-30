require 'test_helper'

class EntityTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( ontology_id comments_count ).each do |column|
      should have_db_column(column).of_type(:integer)
    end
  
    %w( kind name iri range fragment_name ).each do |column|
      should have_db_column(column).of_type(:string)
    end

    should have_db_column('text').of_type(:text)

    should have_db_index([:ontology_id, :id]).unique(true)
    should have_db_index([:ontology_id, :text]).unique(true)
    should have_db_index([:ontology_id, :kind])
  end

  context 'Associations' do
    should belong_to :ontology
    should have_and_belong_to_many :sentences
  end

  context 'OntologyInstance' do
  	setup do
  		@ontology = FactoryGirl.create :single_ontology
  	end

  	context 'creating CommonLogic Entities' do
  		setup do
	  		@entity_hash = {
	  			'name' => 'nat',
	  			'range' => '28.9',
	  			'kind' =>  'sort',
	  			'text' => 'nat'
	  		}

	      @ontology.entities.update_or_create_from_hash @entity_hash
  		end

  		context 'attributes' do
  			setup do
  				@entity = @ontology.entities.first
  			end

  			%w[name range kind text].each do |attr|
  				should "be #{attr}" do
  					assert_equal @entity_hash[attr], eval("@entity.#{attr}")
  				end
  			end       
        
        should "have fragment_name nil" do
          assert_nil @entity.fragment_name
        end
      end
  	end
    
    context 'creating OWL2 Entities' do
      setup do
        @entity = FactoryGirl.create :entity_with_fragment
      end
      
      should "have fragment_name attribute set" do
        assert_equal "Fragment", @entity.fragment_name
      end
    end
  end
end
