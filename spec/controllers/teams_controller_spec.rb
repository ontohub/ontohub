require 'spec_helper'

describe TeamsController do
  context 'not signed in' do
    context 'on GET to index' do
      before { get :index }

      it { should set_the_flash.to(/not authorized/) }
      it { should redirect_to(:root) }
    end
  end

  context 'signed in' do
    let(:user) { create :user }
    before { sign_in user }

    context 'on GET to index without teams' do
      before { get :index }

      it { should respond_with :success }
      it { should render_template :index }
    end

    context 'on GET to new' do
      before { get :new }

      it { should respond_with :success }
      it { should render_template :new }
    end

    context 'with teams' do
      let(:team) { create :team, admin_user: user }

      context 'on GET to index' do
        before { get :index }

        it { should respond_with :success }
        it { should render_template :index }
      end

      context 'on GET to show' do
        before { get :show, id: team.to_param }

        it { should respond_with :success }
        it { should render_template :show }
      end

      context 'on GET to edit' do
        before { get :edit, id: team.to_param }

        it { should respond_with :success }
        it { should render_template :edit }
      end

      context 'on DELETE to destroy' do
        context 'by team admin' do
          before { delete :destroy, id: team.id }

          it { should redirect_to(Team) }
          it { should set_the_flash.to(/destroyed/) }
        end

        context 'by non-admin' do
          let!(:member) { create :user }
          before do
            team.users << member
            sign_in member
            delete :destroy, id: team.id
          end

          it { should redirect_to(:root) }
          it { should set_the_flash.to(/not authorized/) }
        end
      end
    end
  end
end
