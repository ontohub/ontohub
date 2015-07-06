require 'spec_helper'

describe KeysController do
  let(:user){ create :user }
  before { stub_cp_keys }

  context 'not signed in' do
    before { get :index }

    it{ expect(subject).to respond_with :redirect }
  end

  context 'signed in' do
    before { sign_in user }

    context 'GET to new' do
      before { get :new }

      it{ expect(subject).to respond_with :success }
      it{ expect(subject).to render_template :new }
    end

    context 'POST to create' do
      before { post :create, key: attributes_for(:key) }

      it 'sets the flash' do
        expect(flash[:notice]).to match(/successfully created/)
      end
      it{ expect(subject).to redirect_to(:keys) }
    end

    context 'existing key' do
      let!(:key){ create :key, user: user }

      context 'GET to index' do
        before { get :index }

        it{ expect(subject).to respond_with :success }
        it{ expect(subject).to render_template :index }
      end

      context 'DELETE to destroy' do
        before { delete :destroy, id: key.id }

        it{ expect(subject).to redirect_to(:keys) }
      end
    end
  end
end
