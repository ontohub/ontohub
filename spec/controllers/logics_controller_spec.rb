require 'spec_helper'

describe LogicsController do
  let!(:user) { create :user }
  let!(:logic) { create :logic, user: user }

  context 'on GET to show' do
    context 'not signed in' do
      before { get :show, id: logic.to_param }

      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end

    context 'signed in as Logic-Owner' do
      before do
        sign_in user
        get :show, id: logic.to_param
      end

      it { should respond_with :success }
      it { should render_template :show }
      it { should_not set_the_flash }
    end
  end

  context 'in GET to index' do
    before { get :index }

    it { should respond_with :success }
    it { should render_template :index }
    it { should_not set_the_flash }
  end
end
