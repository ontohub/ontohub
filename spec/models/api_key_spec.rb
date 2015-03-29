require 'spec_helper'

describe ApiKey do
  let(:api_key) { create :api_key }

  it 'should have a valid factory' do
    expect(api_key).to be_valid
  end

  context '.create_new_key!' do
    let(:old_key) { create :api_key }
    let!(:key) { described_class.create_new_key!(old_key.user) }

    it 'should only have the new key as valid' do
      expect(described_class.where(status: 'valid').to_a).
        to eq([key])
    end

    it 'should have invalidated the old key' do
      old_key.reload
      expect(old_key.status).to eq('invalid')
    end
  end

  context 'invalid on' do
    it 'non-unique keys' do
      invalid_key = build(:api_key, key: api_key.key)
      expect(invalid_key).to_not be_valid
    end

    it 'non-present user' do
      invalid_key = build(:api_key, user: nil)
      expect(invalid_key).to_not be_valid
    end

    it 'unacceptable status' do
      invalid_key = build(:api_key, status: 'nice status')
      expect(invalid_key).to_not be_valid
    end
  end
end
