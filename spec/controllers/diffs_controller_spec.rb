require 'spec_helper'

describe DiffsController do
  let!(:user){ create(:user) }
  let!(:repository) { create :repository, user: user }

  before do
    repository.save_file(fixture_file('ontologies/xml/empty.xml'), 'hello.txt', 'init', user)
  end

  context 'public read access' do
    context "signed in as owner" do
      before { sign_in user }

      context "show" do
        before { get :show, repository_id: repository.to_param, ref: 'master' }
        it { should respond_with :success }
      end
    end

    context 'signed in without explicit permission' do
      let(:other_user) { create :user }
      before { sign_in other_user }

      context "show" do
        before { get :show, repository_id: repository.to_param, ref: 'master' }
        it { should respond_with :success }
      end
    end

    context "not signed in" do
      context "show" do
        before { get :show, repository_id: repository.to_param, ref: 'master' }
        it { should respond_with :success }
      end
    end
  end

  context 'private read access' do
    before do
      repository.access = 'private_rw'
      repository.save
    end

    context "signed in as owner" do
      before { sign_in user }

      context "show" do
        before { get :show, repository_id: repository.to_param, ref: 'master' }
        it { should respond_with :success }
      end
    end

    context 'signed in without explicit permission' do
      let(:other_user) { create :user }
      before { sign_in other_user }

      context "show" do
        before { get :show, repository_id: repository.to_param, ref: 'master' }
        it { should respond_with :found }
        it { should redirect_to root_path }
        it { should set_the_flash.to(/not authorized/) }
      end
    end

    context "not signed in" do
      context "show" do
        before { get :show, repository_id: repository.to_param, ref: 'master' }
        it { should respond_with :found }
        it { should redirect_to root_path }
        it { should set_the_flash.to(/not authorized/) }
      end
    end
  end
end
