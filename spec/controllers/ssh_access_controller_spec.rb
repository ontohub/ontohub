require 'spec_helper'

describe SSHAccessController do

  let(:repository) { create :repository }
  let(:user) { create :user }

  context 'should return valid response when encountering error' do
    before do
      get :index, repository_id: repository.to_param, key_id: nil, permission: 'write'
    end

    it { should respond_with :success }
    it 'contains error-reason' do
      expect(response.body).to include('reason')
    end
  end

  context 'should return false-permission on valid request without access permission' do
    let!(:key) { create :key, user: user }
    before do
      get :index, repository_id: repository.to_param, key_id: key.id.to_s, permission: 'write'
    end

    it { should respond_with :success }
    it 'contains correct permission' do
      expect(response.body).to include('"allowed":false')
    end

    it 'does not include error-reason' do
      expect(response.body).not_to include('reason')
    end

  end

  context 'should return true-permission on valid request with access permission' do
    let!(:key) { create :key, user: user }
    before do
      get :index, repository_id: repository.to_param, key_id: key.id.to_s, permission: 'read'
    end

    it { should respond_with :success }
    it 'contains correct permission' do
      expect(response.body).to include('"allowed":true')
    end

    it 'does not include error-reason' do
      expect(response.body).not_to include('reason')
    end

  end

  context 'should return false-permission on valid request with write to mirror' do
    let(:repository) { create :repository, source_address: 'http://some_source_address.example.com', source_type: 'git' }
    let!(:key) { create :key, user: user }
    before do
      get :index, repository_id: repository.to_param, key_id: key.id.to_s, permission: 'write'
    end

    it { should respond_with :success }
    it 'contains correct permission' do
      expect(response.body).to include('"allowed":false')
    end

    it 'contains error message which is suitable for the user' do
      expect(response.body).to include('"provide_to_user":true')
    end

  end

end
