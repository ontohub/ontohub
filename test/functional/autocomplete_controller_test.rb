require 'test_helper'

class AutocompleteControllerTest < ActionController::TestCase
  
  should route(:get, "/autocomplete").to(:controller=> :autocomplete, :action => :index)
  
  context 'users and teams' do
    setup do
      @query = 'foo'
      @user = Factory :user, :name => "#{@query}user"
      @team = Factory :team, :name => "#{@query}team"
    end
    
    context 'on GET to index' do
      context 'with results' do
        setup do
          get :index,
            scope: 'user,team',
            query: @query
        end
        
        should respond_with :success
      end
      
      context 'without results' do
        setup do
          get :index,
            scope: 'user,team',
            query: 'xxxyyyzzz'
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
          query: 'bar'
      end
      
      should respond_with :unprocessable_entity
    end
    
    context 'without scope' do
      setup do
        get :index,
          query: 'foo'
      end
      
      should respond_with :success
    end
    
    context 'on GET to index with empty query' do
      setup do
        get :index,
          scope: 'foo',
          query: ''
      end
      
      should respond_with :success
    end
    
    context 'on GET to index without query' do
      setup do
        get :index,
          scope: 'foo'
      end
      
      should respond_with :success
    end
  end

end
