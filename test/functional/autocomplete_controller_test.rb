require 'test_helper'

class AutocompleteControllerTest < ActionController::TestCase

  should route(:get, "/autocomplete").to(:controller=> :autocomplete, :action => :index)

  context 'users and teams' do
    setup do
      @term = 'foo'
      @user = FactoryGirl.create :user, :name => "#{@term}user"
      @team = FactoryGirl.create :team, :name => "#{@term}team"
    end

    context 'on GET to index' do
      context 'with results' do
        setup do
          get :index,
            scope: 'User,Team',
            term:  @term
        end

        should 'return two entries' do
          assert_equal 2, JSON.parse(@response.body).size
        end

        should 'respond with json content type' do
          assert_equal "application/json", response.content_type.to_s
        end

        should respond_with :success
      end

      context 'with results, one excluded' do
        setup do
          get :index,
            scope: 'User,Team',
            term:  @term,
            exclude: {User: @user.id}
        end

        should 'return one entry' do
          assert_equal 1, JSON.parse(@response.body).size
        end

        should 'respond with json content type' do
          assert_equal "application/json", response.content_type.to_s
        end

        should respond_with :success
      end

      context 'without results' do
        setup do
          get :index,
            scope: 'User,Team',
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
      should "throw RuntimeError" do
        assert_raises RuntimeError do
          get :index,
            term:  'foo'
        end
      end

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
