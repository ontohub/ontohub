require 'spec_helper'

describe UrlMapsController do

  describe "url_map" do
    let!(:repository){ create :repository }
    let!(:url_map)   { create :url_map, repository: repository }

    describe "index" do
      before { get :index, repository_id: repository.to_param }
      it { should respond_with :success }
      it { should render_template :index }
    end

    describe "signed in with write access" do
      let(:user){ create(:permission, item: repository).subject }
      before { sign_in user }

      describe "new" do
        before { get :new, repository_id: repository.to_param }
        it { should respond_with :success }
      end

      describe "edit" do
        before { get :edit, repository_id: repository.to_param, id: url_map.to_param }
        it { should respond_with :success }
      end

      describe "create" do
        before { post :create, repository_id: repository.to_param }
        it { should respond_with :success }
      end

      describe "update" do
        before { put :update, repository_id: repository.to_param, id: url_map.to_param }
        it { should respond_with :found }
      end

      describe "destroy" do
        before { delete :destroy, repository_id: repository.to_param, id: url_map.to_param }
        it { should respond_with :found }
      end
    end

    describe "without write access" do
      describe "new" do
        before { get :new, repository_id: repository.to_param }
        it { should respond_with :found }
      end

      describe "edit" do
        before { get :edit, repository_id: repository.to_param, id: url_map.to_param }
        it { should respond_with :found }
      end

      describe "create" do
        before { post :create, repository_id: repository.to_param }
        it { should respond_with :found }
      end

      describe "update" do
        before { put :update, repository_id: repository.to_param, id: url_map.to_param }
        it { should respond_with :found }
      end

      describe "destroy" do
        before { delete :destroy, repository_id: repository.to_param, id: url_map.to_param }
        it { should respond_with :found }
      end
    end
  end

end
