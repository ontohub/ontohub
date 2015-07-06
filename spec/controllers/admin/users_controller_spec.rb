require 'spec_helper'

describe Admin::UsersController do
  context 'on GET to index' do
    context 'not signed in' do
      before { get :index }

      it 'sets the flash' do
        expect(flash[:error]).to match(/admin privileges/)
      end
      it { expect(subject).to respond_with :redirect }
    end

    context 'signed in as normal user' do
      before do
        sign_in create :user
        get :index
      end

      it 'sets the flash' do
        expect(flash[:error]).to match(/admin privileges/)
      end
      it { expect(subject).to respond_with :redirect }
    end

    context 'signed in as admin user' do
      before do
        sign_in create :admin
        get :index
      end

      it { expect(subject).to respond_with :success }
    end
  end
end
