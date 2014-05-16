require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase

  should_map_nested_resources :repositories, :permissions,
    :except => [:new, :edit, :show]

  context 'permissions' do
    setup do
      @ontology = FactoryGirl.create :ontology
      @user     = FactoryGirl.create :user
    end

    context 'on GET to index' do

      context 'not signed in' do
        setup do
          get :index, :repository_id => @ontology.repository.to_param
        end

        should set_the_flash.to(/not authorized/)
        should redirect_to("root path"){ :root }
      end

    end

  end

end
