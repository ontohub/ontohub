require 'spec_helper'

describe ApiKey do
  let(:api_key) { create :api_key }

  it 'should have a valid factory' do
    expect(api_key).to be_valid
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
