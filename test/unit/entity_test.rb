require 'test_helper'

class EntityTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( ontology_id comments_count ).each do |column|
      should have_db_column(column).of_type(:integer)
    end
  
    %w( kind range ).each do |column|
      should have_db_column(column).of_type(:string)
    end

    %w( name display_name label iri text ).each do |column|
      should have_db_column(column).of_type(:text)
    end

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
        
        should "have display_name nil" do
          assert_nil @entity.display_name
        end

        should "have iri nil" do
          assert_nil @entity.iri
        end
      end
  	end
    
    context 'When creating OWL2 Entities' do
      context 'with fragment in URI' do
        setup do
          @entity = FactoryGirl.create :entity_owl2
        end
        
        should 'display_name attribute be the fragment'  do
          assert_equal "1", @entity.display_name
        end

        should 'iri be set'  do
          assert_equal "http://example.com/resource#2", @entity.iri
        end
      end
      
      context 'without fragment in URI, the display_name attribute' do
        setup do
          @entity_hash = {
            'text' => 'Class <http://example.com/resource>',
            'name' => '<http://example.com/resource>'
          }

	        @ontology.entities.update_or_create_from_hash @entity_hash
  				@entity = @ontology.entities.first
        end
        
        should 'be the last path segment' do
          assert_equal "resource", @entity.display_name
        end
      end
    end

    context 'When creating hypothetical entity' do
      context 'where text contains name but name does not match an IRI' do
        context 'display_name and iri' do
          setup do
            @entity_hash = {
              'text' => 'sort s <http://example.com/some_resource>',
              'name' => 's'
            }

            @ontology.entities.update_or_create_from_hash @entity_hash
            @entity = @ontology.entities.first
          end

          should 'be nil' do
            assert_equal nil, @entity.display_name
            assert_equal nil, @entity.iri
          end
        end
      end
    end
  end
end
