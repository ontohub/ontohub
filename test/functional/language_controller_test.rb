require 'test_helper'

class LanguagesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create :user
    @language = FactoryGirl.create :language, :user => @user
  end

  context 'on GET to show' do
    context 'not signed in' do
      setup do
        get :show, :id => @language.to_param
      end

      should respond_with :success
      should render_template :show
      should_not set_the_flash
    end

    context 'signed in as Language-Owner' do
      setup do
        sign_in @user
        get :show, :id => @language.to_param
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
      @language2 = FactoryGirl.build(:language)
      post :create, :language => {
        :name =>  @language2.name,
        :iri => @language2.iri
      }
    end

    should "create the record" do
      assert_equal @language2.name, Language.find_by_name(@language2.name).name
    end

    should respond_with :redirect
    should set_the_flash.to(/created/i)

  end

  context 'on POST to update' do
    context 'signed in' do
      setup do
        sign_in @user
        @oldname = @language.name
        post :update, :id => @language.id, :language => {
          :name => "test3"
        }
      end

      should "not leave the record" do
        assert !Language.find_by_name(@oldname)
      end

      should "change the record" do
        assert Language.find_by_name("test3")
      end

      should respond_with :redirect
      should set_the_flash.to(/successfully updated/i)
    end

    context 'not signed in' do
      setup do
        @oldname = @language.name
        post :update, :id => @language.id, :language => {
          :name => "test3"
        }
      end

      should "leave the record" do
        assert Language.find_by_name(@oldname)
      end

      should "not change the record" do
        assert !Language.find_by_name("test3")
      end

      should respond_with :redirect
      should_not set_the_flash.to(/successfully updated/i)
    end

    context 'not permitted' do
      setup do
        @user2 = FactoryGirl.create :user
        sign_in @user2
        @oldname = @language.name
        post :update, :id => @language.id, :language => {
          :name => "test3"
        }
      end

      should "leave the record" do
        assert Language.find_by_name(@oldname)
      end

      should "not change the record" do
        assert !Language.find_by_name("test3")
      end

      should respond_with :redirect
      should_not set_the_flash.to(/successfully updated/i)
    end

  end

  context 'on POST to DELETE' do
    context 'signed in' do
      setup do
        sign_in @user
        delete :destroy, :id => @language.id
      end

      should "not leave the record" do
        assert !Language.find_by_name(@language.name)
      end

      should respond_with :redirect
      should set_the_flash.to(/successfully destroyed/i)
    end

    context 'not signed in' do
      setup do
        delete :destroy, :id => @language.id
      end

      should "leave the record" do
        assert Language.find_by_name(@language.name)
      end

     should respond_with :redirect
      should_not set_the_flash.to(/successfully destroyed/i)
    end

    context 'not permitted' do
      setup do
        @user2 = FactoryGirl.create :user
        sign_in @user2
        delete :destroy, :id => @language.id
      end

      should "leave the record" do
        assert Language.find_by_name(@language.name)
      end

      should respond_with :redirect
      should_not set_the_flash.to(/successfully destroyed/i)
    end

  end

end
