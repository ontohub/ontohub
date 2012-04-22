require 'test_helper'

class LogicTranslationsControllerTest < ActionController::TestCase
  setup do
    @logic_translation = logic_translations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:logic_translations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create logic_translation" do
    assert_difference('LogicTranslation.count') do
      post :create, logic_translation: @logic_translation.attributes
    end

    assert_redirected_to logic_translation_path(assigns(:logic_translation))
  end

  test "should show logic_translation" do
    get :show, id: @logic_translation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @logic_translation
    assert_response :success
  end

  test "should update logic_translation" do
    put :update, id: @logic_translation, logic_translation: @logic_translation.attributes
    assert_redirected_to logic_translation_path(assigns(:logic_translation))
  end

  test "should destroy logic_translation" do
    assert_difference('LogicTranslation.count', -1) do
      delete :destroy, id: @logic_translation
    end

    assert_redirected_to logic_translations_path
  end
end
