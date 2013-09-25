require 'test_helper'

class GraphsControllerTest < ActionController::TestCase

  should route(:get, "/logics/id/graphs").to(:controller=> :graphs, :action => :index, :logic_id => 'id')

  setup do
    @source = FactoryGirl.create(:logic)
    @target = FactoryGirl.create(:logic)
    @mapping = FactoryGirl.create(:logic_mapping,
                                  source: @source,
                                  target: @target)
  end

  context 'on GET to index' do
    context 'valid on json-request' do
      setup do
        get :index, logic_id: @source, format: :json
      end

      should respond_with :success
    end
    context 'valid on html-request' do
      setup do
        get :index, logic_id: @source, format: :html
      end

      should respond_with :success
    end
    context 'valid response when there are no mappings/links' do
      setup do
        @unlinked_source = FactoryGirl.create(:logic)
        get :index, logic_id: @unlinked_source, format: :json
      end

      should respond_with :success
    end
  end

end
