require 'spec_helper'

describe UsersController do
  let!(:user) { create :user }

  context 'without data' do
    context 'on GET to show' do
      before { get :show, id: user.to_param }

      it { expect(subject).to respond_with :success }
      it { expect(subject).to render_template :show }
    end
  end

  context 'with data' do
    before do
      create :comment, user: user
      create :ontology_version_with_file, user: user
    end
    context 'on GET to show' do
      before { get :show, id: user.to_param }

      it { expect(subject).to respond_with :success }
      it { expect(subject).to render_template :show }
    end
  end
end
