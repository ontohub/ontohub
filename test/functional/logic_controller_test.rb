require 'test_helper'

class LogicsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create :user
    @logic = FactoryGirl.create :logic, :user => @user
  end

  context 'on GET to show' do
    context 'not signed in' do
      setup do
        get :show, :id => @logic.to_param
      end

      should respond_with :success
      should render_template :show
      should_not set_the_flash
    end

    context 'signed in as Logic-Owner' do
      setup do
        sign_in @user
        get :show, :id => @logic.to_param
      end

      should respond_with :success
      should render_template :show
      should_not set_the_flash
    end
  end

  context 'in GET to index' do
    setup do
      get :index
    end

    should respond_with :success
    should render_template :index
    should_not set_the_flash
  end

  context 'add Language to Logic' do
    setup do
      @language = FactoryGirl.create(:Language)
      sign_in @user
      post :add_language, :id => @logic.id,:name => @language.name
    end
#    @logic.supports.each do |sup|
#        contains = false
#        if sup.language == @language
#          contains = true
#        end
#    end
#    should "add the Languagesupport" do
#      assert contains
#    end
  end

end
