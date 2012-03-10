require 'test_helper'

class AutocompleteControllerTest < ActionController::TestCase
  
  should route(:get, "/autocomplete").to(:controller=> :autocomplete, :action => :index)
  
  context 'users and teams' do
    setup do
      @term = 'foo'
      @user = Factory :user, :name => "#{@term}user"
      @team = Factory :team, :name => "#{@term}team"
    end
    
    context 'on GET to index' do
      context 'with results' do
        setup do
          get :index,
            scope: 'user,team',
            term:  @term
        end
        
        should respond_with_content_type :json
        should respond_with :success
      end
      
      context 'without results' do
        setup do
          get :index,
            scope: 'user,team',
            term:  'xxxyyyzzz'
        end
        
        should respond_with :success
      end
    end
    
  end
  
  context 'on GET to index' do
    context 'with invalid scope' do
      setup do
        get :index,
          scope: 'foo',
          term:  'bar'
      end
      
      should respond_with :unprocessable_entity
    end
    
    context 'without scope' do
      setup do
        get :index,
          term:  'foo'
      end
      
      should respond_with :success
    end
    
    context 'on GET to index with empty term' do
      setup do
        get :index,
          scope: 'foo',
          term:  ''
      end
      
      should respond_with :success
    end
    
    context 'on GET to index without term' do
      setup do
        get :index,
          scope: 'foo'
      end
      
      should respond_with :success
    end
  end

end
