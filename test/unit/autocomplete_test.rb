require 'test_helper'

class AutocompleteTest < ActiveSupport::TestCase
  
  context 'for users and teams' do
    setup do
      @foo    = Factory :user, :name => 'foo'
      @foobar = Factory :user, :name => 'foobar'
      
      @team_bars = Factory :team, :name => 'special bars'
      @team_faker = Factory :team, :name => 'faker'
      
      # should never be found
      Factory :user, :name => 'xxyyzz'
      Factory :team, :name => 'aabbbccc'
    end
    
    context 'searching for user' do
      
      # two results
      context 'foo' do
        setup do
          autocomplete 'user', @foo.name
        end
        
        should 'find two users' do
          assert_equal 2, @result.size
        end
      end
      
      # one result
      context 'foobar' do
        context 'by name' do
          setup do
            autocomplete 'user', @foobar.name
          end
          
          should 'find the user' do
            assert_equal [@foobar], @result
          end
        end
        
        context 'by email' do
          setup do
            autocomplete 'user', @foobar.email
          end
          
          should 'find the user' do
            assert_equal [@foobar], @result
          end
        end
      end
      
      # no results
      context 'baz' do
        setup do
          autocomplete 'user', 'baz'
        end
        
        should 'not found any users' do
          assert_equal 0, @result.size
        end
      end
    end
    
    context 'searching user and team' do
      # 1 user + 1 team
      context 'bar' do
        setup do
          autocomplete 'user,team', 'bar'
        end
        
        should 'get two results' do
          assert_equal 2, @result.size
        end
        
        should 'find the user' do
          assert @result.include?(@foobar)
        end
        
        should 'find the team' do
          assert @result.include?(@team_bars)
        end
      end
      
      # 1 1 team
      context 'faker' do
        setup do
          autocomplete 'user,team', @team_faker.name
        end
        
        should 'find the team' do
          assert @result.include?(@team_faker)
        end
      end
    end
    
  end
  
  def autocomplete(scope, query)
    @result = Autocomplete.new(scope, query).result
  end
  
end
