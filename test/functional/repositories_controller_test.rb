require 'test_helper'

class RepositoriesControllerTest < ActionController::TestCase

  should route(:get, "/repositories").to(:controller=> :repositories, :action => :index)
  should route(:get, "/repositories/id").to(:controller=> :repositories, :action => :show, id: 'id')

  context 'Repository instance' do
    setup do
      @repository = FactoryGirl.create :repository
    end

    context 'on GET to index' do
      setup do
        get :index
      end

      should respond_with :success
      should render_template :index
      should render_template 'repositories/_repository'
    end

    context 'on GET to show' do
      setup do
        get :show, id: @repository.path
      end

      should respond_with :success
      should render_template :show
    end

  end

end
