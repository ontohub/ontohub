require 'test_helper'

class GraphsControllerTest < ActionController::TestCase

  should route(:get, "/logics/id/graphs").to(:controller=> :graphs, :action => :index, :logic_id => 'id')

  setup do
    @user = FactoryGirl.create :user
    @source = FactoryGirl.create(:logic, user: @user)
    @target = FactoryGirl.create(:logic, user: @user)
    @mapping = FactoryGirl.create(:logic_mapping,
                                  source: @source,
                                  target: @target,
                                  user: @user)
  end

  context 'on GET to index' do
    context 'invalid on non-json request' do
      setup do
        get :index, logic_id: @source
      end

      should respond_with 406
    end
    context 'valid on json-request' do
      setup do
        get :index, logic_id: @source, format: :json
      end

      should respond_with :success
    end
  end

end
