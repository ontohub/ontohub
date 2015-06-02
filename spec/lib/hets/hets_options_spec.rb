require 'spec_helper'

describe Hets::HetsOptions do
  let(:options) { {key1: 'value1', key2: 'value2'} }

  context 'initialize' do
    it 'sets options' do
      expect(Hets::HetsOptions.new(options).options).to eq(options)
    end

    it 'removes nil valued options' do
      options_new = {**options, key3: nil}
      expect(Hets::HetsOptions.new(options_new).options).to eq(options)
    end
  end

  context 'from_hash' do
    it 'sets options' do
      hash = {'options' => options}
      expect(Hets::HetsOptions.from_hash(hash).options).to eq(options)
    end

    it 'removes nil valued options' do
      options_new = {**options, key3: nil}
      hash = {'options' => options_new}
      expect(Hets::HetsOptions.from_hash(hash).options).to eq(options)
    end
  end

  context 'add' do
    let(:hets_options) { Hets::HetsOptions.new(options) }
    let(:additional_options) { {key3: 'value3', key4: 'value4'} }

    it 'adds options' do
      hets_options.add(additional_options)
      expect(hets_options.options).to eq(options.merge(additional_options))
    end

    it 'removes nil valued options' do
      additional_options_new = {**additional_options, key5: nil}
      hets_options.add(additional_options_new)
      expect(hets_options.options).to eq(options.merge(additional_options))
    end
  end

  context 'access token' do
    context 'access token is nil' do
      let(:access_token_options) { {**options, :'access-token' => nil} }
      let(:hets_options) { Hets::HetsOptions.new(access_token_options) }

      it 'has no access token key' do
        expect(hets_options.options.has_key?(:'access-token')).to be(false)
      end
    end

    context 'access token exists' do
      let(:access_token) { create :access_token }
      let(:access_token_options) { {**options, :'access-token' => access_token} }
      let(:hets_options) { Hets::HetsOptions.new(access_token_options) }

      it 'has the correct access token' do
        expect(hets_options.options[:'access-token']).to eq(access_token.to_s)
      end
    end
  end

  context 'url-catalog' do
    context 'empty' do
      let(:catalog_options) { {**options, :'url-catalog' => %w()} }
      let(:hets_options) { Hets::HetsOptions.new(catalog_options) }

      it "removes the key :'url-catalog'" do
        expect(hets_options.options.has_key?(:'url-catalog')).to be(false)
      end
    end

    context 'only with nil values' do
      let(:catalog_options) { {**options, :'url-catalog' => [nil, nil]} }
      let(:hets_options) { Hets::HetsOptions.new(catalog_options) }

      it "removes the key :'url-catalog'" do
        expect(hets_options.options.has_key?(:'url-catalog')).to be(false)
      end
    end

    context 'with a nil value' do
      let(:catalog_options) do
        {**options, :'url-catalog' => ['a=b', nil, 'c=d']}
      end
      let(:hets_options) { Hets::HetsOptions.new(catalog_options) }

      it "removes the nil value from  :'url-catalog'" do
        expect(hets_options.options[:'url-catalog']).to eq('a=b,c=d')
      end
    end

    context 'without nil values' do
      let(:catalog_options) { {**options, :'url-catalog' => %w(a=b c=d)} }
      let(:hets_options) { Hets::HetsOptions.new(catalog_options) }

      it "has the same :'url-catalog'" do
        expect(hets_options.options[:'url-catalog']).to eq('a=b,c=d')
      end
    end
  end
end
