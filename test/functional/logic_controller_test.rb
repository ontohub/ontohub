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

  context 'on POST to create' do
    setup do
      sign_in @user
      @logic2 = FactoryGirl.build(:logic)
      post :create, :logic => {
        :name =>  @logic2.name,
        :iri => @logic2.iri
      }
    end

    should "create the record" do
      assert_equal @logic2.name, Logic.find_by_name(@logic2.name).name
    end

    should respond_with :redirect
    should set_the_flash.to(/created/i)

  end

  context 'on POST to update' do
    context 'signed in' do
      setup do
#        @logic.permissions.create! \
#            :role    => 'owner',
#            :subject => @user
        sign_in @user
        @oldname = @logic.name
        post :update, :id => @logic.id, :logic => {
          :name => "test3"
        }
      end

      should "not leave the record" do
        assert !Logic.find_by_name(@oldname)
      end

      should "change the record" do
        assert Logic.find_by_name("test3")
      end

      should respond_with :redirect
      should set_the_flash.to(/successfully updated/i)
    end

    context 'not signed in' do
      setup do
#        @logic.permissions.create! \
#            :role    => 'owner',
#            :subject => @user
        @oldname = @logic.name
        post :update, :id => @logic.id, :logic => {
          :name => "test3"
        }
      end

      should "leave the record" do
        assert Logic.find_by_name(@oldname)
      end

      should "not change the record" do
        assert !Logic.find_by_name("test3")
      end

      should respond_with :redirect
      should_not set_the_flash.to(/successfully updated/i)
    end

    context 'not permitted' do
      setup do
        @user2 = FactoryGirl.create :user
        sign_in @user2
        @oldname = @logic.name
        post :update, :id => @logic.id, :logic => {
          :name => "test3"
        }
      end

      should "leave the record" do
        assert Logic.find_by_name(@oldname)
      end

      should "not change the record" do
        assert !Logic.find_by_name("test3")
      end

      should respond_with :redirect
      should_not set_the_flash.to(/successfully updated/i)
    end

  end

    context 'on POST to DELETE' do
    context 'signed in' do
      setup do
#        @logic.permissions.create! \
#            :role    => 'owner',
#            :subject => @user
        sign_in @user
        delete :destroy, :id => @logic.id
      end

      should "not leave the record" do
        assert !Logic.find_by_name(@logic.name)
      end

      should respond_with :redirect
      should set_the_flash.to(/successfully destroyed/i)
    end

    context 'not signed in' do
      setup do
#        @logic.permissions.create! \
#            :role    => 'owner',
#            :subject => @user
        delete :destroy, :id => @logic.id
      end

      should "leave the record" do
        assert Logic.find_by_name(@logic.name)
      end

     should respond_with :redirect
      should_not set_the_flash.to(/successfully destroyed/i)
    end

    context 'not permitted' do
      setup do
        @user2 = FactoryGirl.create :user
        sign_in @user2
        delete :destroy, :id => @logic.id
      end

      should "leave the record" do
        assert Logic.find_by_name(@logic.name)
      end

      should respond_with :redirect
      should_not set_the_flash.to(/successfully destroyed/i)
    end

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
