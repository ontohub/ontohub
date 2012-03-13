require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  
  should route(:get,  "/ontologies/ontology_id/comments").to(:controller=> :comments, :action => :index, :ontology_id => 'ontology_id')
  should route(:post, "/ontologies/ontology_id/comments").to(:controller=> :comments, :action => :create, :ontology_id => 'ontology_id')
  
  context 'ontology' do
    setup do
      @ontology = Factory :ontology
      @user     = Factory :user
    end
    
    context 'not signed in' do
      
      context 'on GET to index' do
        context 'without comment' do
          setup do
            get :index, :ontology_id => @ontology.to_param
          end
          
          should respond_with :success
          should render_template 'comments/index'
        end
        
        context 'with comment' do
          setup do
            @comment = Factory :comment, :commentable => @ontology
            get :index, :ontology_id => @ontology.to_param
          end
          
          should respond_with :success
          should render_template 'comments/index'
        end
      end
    end
    
    context 'signed in' do
      
      setup do
        sign_in @user
      end
      
      context 'on GET to index' do
        context 'without comment' do
          setup do
            get :index, :ontology_id => @ontology.to_param
          end
          
          should respond_with :success
          should render_template 'comments/index'
        end
        
        context 'with comment' do
          setup do
            @comment = Factory :comment, :commentable => @ontology
            get :index, :ontology_id => @ontology.to_param
          end
          
          should respond_with :success
          should render_template 'comments/index'
        end
        
        context 'on POST to delete' do
          setup do
            @comment = Factory :comment, :commentable => @ontology, :user => @user
            xhr :delete, :destroy, :ontology_id => @ontology.to_param, :id => @comment.id
          end
          
          should respond_with :success
        end
      end
      
      context 'on POST to create' do
        context 'with too short text' do
          setup do
            xhr :post, :create,
              ontology_id: @ontology.to_param,
              comment:     {text: 'foo'}
          end
          should respond_with :unprocessable_entity
        end

        context 'with too enough text' do
          setup do
            xhr :post, :create,
              ontology_id: @ontology.to_param,
              comment:     {text: 'fooo baaaaaaaaaaaaaaar'}
          end
          
          should respond_with :success
        end
      end
    end
    
  end

end
