require 'spec_helper'

describe UsersController do
  let!(:user) { create :user }

  context 'without data' do
    context 'on GET to show' do
      before { get :show, id: user.to_param }

      it { should respond_with :success }
      it { should render_template :show }
    end
  end

  context 'with data' do
    before do
      create :comment, user: user
      ontology_version = create :ontology_version_with_file
      commit = ontology_version.commit
      commit.pusher = user
      commit.save!
    end
    context 'on GET to show' do
      before { get :show, id: user.to_param }

      it { should respond_with :success }
      it { should render_template :show }
    end
  end
end
