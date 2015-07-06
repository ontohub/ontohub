require 'spec_helper'

describe LicenseModelsController do

  let!(:license_model)   { create :license_model }

  context "signed in" do
    let(:user){ create(:user) }
    before { sign_in user }

    context "index" do
      before { get :index }
      it { expect(subject).to respond_with :success }
    end

    context "show" do
      context 'requesting standard representation' do
        before { get :show, id: license_model.to_param }

        it { expect(subject).to respond_with :success }
        it { expect(subject).to render_template :show }
      end
    end

    context "new" do
      before { get :new }
      it { expect(subject).to respond_with :success }
    end

    context "edit" do
      before { get :edit, id: license_model.to_param }
      it { expect(subject).to respond_with :found }
    end

    context "create" do
      before { post :create }
      it { expect(subject).to respond_with :success }
    end

    context "update" do
      before { put :update, id: license_model.to_param }
      it { expect(subject).to respond_with :found }
    end

    context "destroy" do
      before { delete :destroy, id: license_model.to_param }
      it { expect(subject).to respond_with :found }
    end
  end

  context "not signed in" do
    context "index" do
      before { get :index }
      it { expect(subject).to respond_with :success }
    end

    context "show" do
      before { get :show, id: license_model.id }
      it { expect(subject).to respond_with :success }
    end

    context "new" do
      before { get :new }
      it { expect(subject).to respond_with :found }
    end

    context "edit" do
      before { get :edit, id: license_model.to_param }
      it { expect(subject).to respond_with :found }
    end

    context "create" do
      before { post :create }
      it { expect(subject).to respond_with :found }
    end

    context "update" do
      before { put :update, id: license_model.to_param }
      it { expect(subject).to respond_with :found }
    end

    context "destroy" do
      before { delete :destroy, id: license_model.to_param }
      it { expect(subject).to respond_with :found }
    end
  end

end
