require 'spec_helper'

describe KeysController do

  let(:user){ create :user }

  context 'not signed in' do
    before do
      get :index
    end

    it{ should respond_with :redirect }
  end

  context 'signed in' do
    before do
      sign_in user
    end

    context 'GET to new' do
      before do
        get :new
      end

      it{ should respond_with :success }
      it{ should render_template :new }
    end

    context 'POST to create' do
      before do
        post :create, key: attributes_for(:key)
      end

      it{ should set_the_flash.to(/successfully created/) }
      it{ should redirect_to(:keys) }
    end

    context 'existing key' do
      let!(:key){ create :key, user: user }

      context 'GET to index' do
        before do
          get :index
        end

        it{ should respond_with :success }
        it{ should render_template :index }
      end

      context 'DELETE to destroy' do
        before do
          delete :destroy, id: key.id
        end

        it{ should redirect_to(:keys) }
      end
    end
  end

end
