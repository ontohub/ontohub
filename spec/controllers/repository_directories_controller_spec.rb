require 'spec_helper'

describe RepositoryDirectoriesController do
  let(:user) { create :user }
  let(:repository) { create :repository, user: user }

  context 'not signed in: create' do
    before do
      post :create, repository_directory: attributes_for(:repository_directory), repository_id: repository.to_param
    end

    it{ should respond_with :redirect }
  end

  context 'signed in' do
    before do
      sign_in user
    end

    context 'POST to create' do
      let(:target) { generate :name }
      let(:name) { generate :name }

      before do
        post :create, repository_directory: {
            target_directory: target,
            name: name
          }, repository_id: repository.to_param
      end

      it { should respond_with(201) }
    end

    context 'POST to create when it already exists' do
      let(:target) { generate :name }
      let(:name) { generate :name }
      let(:repo_dir) do
        create :repository_directory, repository: repository, user: user,
          name: name, target_directory: target
      end

      before do
        post :create, repository_directory: {
            target_directory: repo_dir.target_directory,
            name: repo_dir.name
          }, repository_id: repository.to_param
      end

      it { should respond_with(422) }
    end
  end

end
