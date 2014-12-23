require 'spec_helper'

describe KeysController do

  let(:user){ create :user }

  context 'not signed in' do
    before { get :index }

    it{ should respond_with :redirect }
  end

  context 'signed in' do
    before { sign_in user }

    context 'GET to new' do
      before { get :new }

      it{ should respond_with :success }
      it{ should render_template :new }
    end

    context 'POST to create' do
      before { post :create, key: attributes_for(:key) }

      it{ should set_the_flash.to(/successfully created/) }
      it{ should redirect_to(:keys) }
    end

    context 'existing key' do
      let!(:key){ create :key, user: user }

      context 'GET to index' do
        before { get :index }

        it{ should respond_with :success }
        it{ should render_template :index }
      end

      context 'DELETE to destroy' do
        before { delete :destroy, id: key.id }

        it{ should redirect_to(:keys) }
      end
    end
  end

end
