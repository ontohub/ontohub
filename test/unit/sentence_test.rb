require 'test_helper'

class SentenceTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( ontology_id comments_count ).each do |column|
      should have_db_column(column).of_type(:integer)
    end   
  
    %w( name range ).each do |column|
      should have_db_column(column).of_type(:string)
    end

    %w( text display_text ).each do |column|
      should have_db_column(column).of_type(:text)
    end

    should have_db_index([:ontology_id, :id]).unique(true)
    should have_db_index([:ontology_id, :name]).unique(true)
  end

  context 'Associations' do
    should belong_to :ontology
    should have_and_belong_to_many :entities
  end

  context 'OntologyInstance' do
  	setup do
  		@ontology = FactoryGirl.create :single_ontology
  	end

  	context 'creating Sentences' do
  		setup do
	  		@sentence_hash = {
	  			'name' => '... (if exists)',
          'range' => 'Examples/Reichel:40.9'
	  		}

	      @ontology.sentences.update_or_create_from_hash @sentence_hash
  		end

  		context 'correct attribute' do
  			setup do
  				@sentence = @ontology.sentences.first
  			end

  			%w[name range].each do |attr|
  				should "be #{attr}" do
  					assert_equal @sentence_hash[attr], eval("@sentence.#{attr}")
  				end
  			end
  		end
  	end

#   context 'OWL2 sentences' do
#     setup do
#       @sentence = FactoryGirl.build :sentence
#       3.times do
#         @sentence.ontology.entities << FactoryGirl.build(:entity_owl2)
#       end
#       @sentence.text = @sentence.entities.map(&:iri).map { |x| "<#{x}> " }.join.strip
#       @sentence.save!
#     end

#     should 'not contain entitys iri' do
#       p @sentence.entities
#       @sentence.entities.each do |x|
#         assert !(@sentence.text.include? x.iri)
#       end
#     end
#   end
  end

end
