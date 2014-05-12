require 'spec_helper'

describe Api::V1::OntologiesController do

  render_views

  let(:user){ create :user }
  let!(:ontology){ create :ontology }

  before{ request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.email, user.password) }

  context 'index by basepath and repository_id' do
    before do
      get :index,
        format:        :json,
        repository_id: ontology.repository_id,
        basepath:      ontology.basepath
    end

    it{ should respond_with :success }
  end

  context 'update' do
    let(:params){{
      id:       ontology.id,
      format:   :json,
      ontology: {description: 'foobar'}
    }}

    context 'without permission' do
      before do
        put :update, params

      end
      it{ should respond_with :forbidden }
    end

    context 'with permission' do
      before do
        create :permission, subject: user, item: ontology.repository
        put :update, params
      end
      it{ should respond_with :no_content }
    end
  end
end
