require 'spec_helper'

describe RepositorySettingsController do
  context '#index' do
    # Redirecting in SettingsControler to url Maps because SettingsController
    # is only a meta controller
    let(:repository){ create :repository }
    before do
      get :index, repository_id: repository.to_param
    end

    it 'should redirect to url_maps index' do
      response.should redirect_to [repository, :url_maps]
    end
  end
end
