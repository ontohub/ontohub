require 'test_helper'

class SentencesControllerTest < ActionController::TestCase
  
  should route(:get, "/ontologies/id/versions/number/sentences").to(
    :controller => :sentences,
    :action => :index,
    :ontology_id => 'id',
    :number => 'number'
  )
  
  context 'Ontology Instance' do
    setup do
      @sentence = Factory :sentence
      @version  = @sentence.ontology_version
      @ontology = @sentence.ontology
    end
    
    context 'on GET to index' do
      setup do
        get :index,
          :ontology_id => @ontology.to_param,
          :number      => @version.number
      end
      
      should respond_with :success
      should render_template :index
      should render_template 'sentences/_sentence'
    end
    
  end
  
end
