require 'spec_helper'

describe TeamUsersController do
  render_views

  let!(:admin) { create :user } # team admin
  let!(:user)  { create :user }
  let!(:team)  { create :team, admin_user: admin }

  context 'on GET to index' do
    context 'as admin' do
      before do
        sign_in admin
        get :index, team_id: team.to_param
      end

      it { should render_template 'relation_list/_relation_list' }
      it { should render_template :index }
      it { should respond_with :success }
    end

    context 'as user' do
      before do
        sign_in user
        get :index, team_id: team.to_param
      end
      it { should set_the_flash.to(/not authorized/) }
      it { should redirect_to(:root) }
    end
  end

  context 'adding a user' do
    context 'by admin' do
      before do
        sign_in admin
        xhr :post, :create, team_id: team.id, team_user: { user_id: user.id }
      end

      it { should render_template 'team_users/_team_user' }
      it { should respond_with :success }
    end
  end

  context 'with one user' do
    context 'removing the last user' do
      before do
        sign_in admin
        xhr :delete, :destroy, team_id: team.id, id: team.team_users.first.id
      end

      it 'return a helpful error message' do
        expect(response.body).to match(/What the hell/)
      end

      it { should respond_with :unprocessable_symbol }
    end
  end

  context 'with two users' do
    let!(:team_user) { team.team_users.create! user: user }

    context 'setting the admin flag' do
      before do
        sign_in admin
        xhr :put, :update,
          team_id: team.id, id: team_user.id, team_user: { admin: 1 }
      end

      it { should render_template 'team_users/_team_user' }
      it { should respond_with :success }
    end

    context 'team admin deleting other user' do
      before do
        sign_in admin
        xhr :delete, :destroy, team_id: team.id, id: team_user.id
      end

      it { should respond_with :success }
    end

  end
end
