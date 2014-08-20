require 'spec_helper'

describe AccessToken do
  let(:access_token) { create :access_token }
  let(:repository) { create :repository, access_token: access_token }

  context 'expired?' do
    it 'should not be expired when the expiration date is in the future' do
      expect(access_token.expired?).to be_falsy
    end

    it 'should be expired when the expiration date is in the past' do
      access_token.expiration = (-1).minutes.from_now
      expect(access_token.expired?).to be_truthy
    end
  end

  context 'refresh' do
    let!(:old_access_token) { access_token.dup }
    before do
      access_token.expiration = (-1).minutes.from_now
    end

    it 'should be expired before refresh' do
      expect(access_token.expired?).to be_truthy
    end

    context 'after refresh' do
      before do
        access_token.refresh!
      end

      it 'should not be expired' do
        expect(access_token.expired?).to be_falsy
      end

      it 'should have the same token' do
        expect(access_token.token).to eq(old_access_token.token)
      end
    end
  end

  context 'replacement' do
    let!(:replacement) { access_token.replace }

    it 'should delete the old token' do
      expect(access_token.persisted?).to be_falsy
    end

    it 'should generate another token' do
      expect(replacement.token).not_to eq(access_token.token)
    end
  end
end
