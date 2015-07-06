require 'spec_helper'

describe TasksController do

  let!(:task)   { create :task }

  context "signed in" do
    let(:user){ create(:user) }
    before { sign_in user }

    context "index" do
      before { get :index }
      it { expect(subject).to respond_with :success }
    end

    context "show" do
      before { get :show, id: task.id }
      it { expect(subject).to respond_with :success }
    end

    context "new" do
      before { get :new }
      it { expect(subject).to respond_with :success }
    end

    context "edit" do
      before { get :edit, id: task.to_param }
      it { expect(subject).to respond_with :found }
    end

    context "create" do
      before { post :create }
      it { expect(subject).to respond_with :success }
    end

    context "update" do
      before { put :update, id: task.to_param }
      it { expect(subject).to respond_with :found }
    end

    context "destroy" do
      before { delete :destroy, id: task.to_param }
      it { expect(subject).to respond_with :found }
    end
  end

  context "not signed in" do
    context "index" do
      before { get :index }
      it { expect(subject).to respond_with :success }
    end

    context "show" do
      before { get :show, id: task.id }
      it { expect(subject).to respond_with :success }
    end

    context "new" do
      before { get :new }
      it { expect(subject).to respond_with :found }
    end

    context "edit" do
      before { get :edit, id: task.to_param }
      it { expect(subject).to respond_with :found }
    end

    context "create" do
      before { post :create }
      it { expect(subject).to respond_with :found }
    end

    context "update" do
      before { put :update, id: task.to_param }
      it { expect(subject).to respond_with :found }
    end

    context "destroy" do
      before { delete :destroy, id: task.to_param }
      it { expect(subject).to respond_with :found }
    end
  end

end
