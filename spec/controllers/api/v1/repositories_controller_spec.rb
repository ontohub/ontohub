require 'spec_helper'

describe Api::V1::RepositoriesController do

  let(:user){ create :user }

  context 'unauthenticated' do
    before do
      get :index, format: :json
    end

    it{ should respond_with :unauthorized }
  end

  context 'http authenticated' do
    context 'wrong credentials' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.email, user.password + "x")
        get :index, format: :json
      end

      it{ should respond_with :unauthorized }
    end

    context 'correct credentials' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.email, user.password)
        get :index, format: :json
      end

      it{ should respond_with :success }
    end
  end
end
