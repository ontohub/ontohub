require 'spec_helper'

describe LogicsController do
  let!(:user) { FactoryGirl.create :user }
  let!(:logic) { FactoryGirl.create :logic, user: user }

  context 'on GET to show' do
    context 'not signed in' do
      before do
        get :show, id: logic.to_param
      end

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
    before do
      get :index
    end

    it { should respond_with :success }
    it { should render_template :index }
    it { should_not set_the_flash }
  end
end
