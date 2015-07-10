require 'spec_helper'

describe AccessTokenDeletionWorker do
  before do
    Worker.clear
    [-2, -1, 1].map { |h| h.hours.from_now }.each do |expiration|
      create :access_token, expiration: expiration
    end
  end

  it 'before perfoming there should be 3 tokens' do
    expect(AccessToken.count).to eq(3)
  end

  context 'after perfoming' do
    before { AccessTokenDeletionWorker.new.perform }

    it 'there should be only 1 token' do
      expect(AccessToken.count).to eq(1)
    end
  end
end
