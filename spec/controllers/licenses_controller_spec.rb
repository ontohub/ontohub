require 'spec_helper'

describe LicensesController do

  let!(:license)   { create :license }

  context "signed in" do
    let(:user){ create(:user) }
    before { sign_in user }

    context "index" do
      before { get :index }
      it { should respond_with :success }
    end

    context "show" do
      before { get :show, id: license.id }
      it { should respond_with :success }
    end

    context "new" do
      before { get :new }
      it { should respond_with :success }
    end

    context "edit" do
      before { get :edit, id: license.to_param }
      it { should respond_with :found }
    end

    context "create" do
      before { post :create }
      it { should respond_with :success }
    end

    context "update" do
      before { put :update, id: license.to_param }
      it { should respond_with :found }
    end

    context "destroy" do
      before { delete :destroy, id: license.to_param }
      it { should respond_with :found }
    end
  end

  context "not signed in" do
    context "index" do
      before { get :index }
      it { should respond_with :success }
    end

    context "show" do
      before { get :show, id: license.id }
      it { should respond_with :success }
    end

    context "new" do
      before { get :new }
      it { should respond_with :found }
    end

    context "edit" do
      before { get :edit, id: license.to_param }
      it { should respond_with :found }
    end

    context "create" do
      before { post :create }
      it { should respond_with :found }
    end

    context "update" do
      before { put :update, id: license.to_param }
      it { should respond_with :found }
    end

    context "destroy" do
      before { delete :destroy, id: license.to_param }
      it { should respond_with :found }
    end
  end

end
