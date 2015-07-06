require 'spec_helper'

describe Teams::PermissionsController do
  let!(:team) { create :team }
  let!(:permission) { create :permission, subject: team }

  context 'on GET to index' do
    context 'not signed in' do
      before { get :index, team_id: team.to_param }

      it 'sets the flash' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it { expect(subject).to respond_with :redirect }
    end

    context 'signed in as normal user' do
      render_views

      before do
        sign_in create :user
        get :index, team_id: team.to_param
      end

      it { expect(subject).to respond_with :success }
      it { expect(subject).to render_template :index }
      it { expect(subject).to render_template 'teams/permissions/_permission' }
    end
  end
end
