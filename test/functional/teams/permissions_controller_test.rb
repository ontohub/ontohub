require 'test_helper'

class Teams::PermissionsControllerTest < ActionController::TestCase

  should route(:get, "/teams/team_id/permissions").to(:controller=> 'teams/permissions', :action => :index, :team_id => 'team_id')

  context 'team' do
    setup do
      @team = FactoryGirl.create :team
      FactoryGirl.create :permission, :subject => @team
    end

    context 'on GET to index' do

      context 'not signed in' do
        setup do
          get :index, :team_id => @team.to_param
        end

        should set_the_flash.to(/not authorized/)
        should respond_with :redirect
      end

      context 'signed in as normal user' do
        setup do
          sign_in FactoryGirl.create :user
          get :index, :team_id => @team.to_param
        end

        should respond_with :success
        should render_template :index
        should render_template 'teams/permissions/_permission'
      end
    end
  end

end
