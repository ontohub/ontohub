require 'spec_helper'

describe Oops do
  WebMock.allow_net_connect!(net_http_connect_on_start: true)

  context 'doing a oops request' do
    context 'with invalid url' do
      it 'raise error' do
        expect { do_request :invalid, url: 'http://example.com/' }.
          to raise_error(Oops::Error, /reach ontohub/)
      end
    end

    context 'with valid url' do
      let!(:result) do
        do_request :valid, url: 'http://sweet.jpl.nasa.gov/1.1/sunrealm.owl'
      end
      it 'return a list' do
        expect(result.size).to eq(2)
      end
    end
  end

  context 'parsing a oops response' do
    let!(:result) do
      Oops::Response.parse File.read(
        "#{Rails.root}/test/fixtures/oops/sunrealm.xml")
    end
    it 'return correct amount of elements' do
      expect(result.size).to eq(5)
    end

    context 'first element responded' do
      let!(:element) { result.first }

      it 'have correct type' do
        expect(element.type).to eq('Pitfall')
      end

      it 'have correct name' do
        expect(element.name).to eq('Creating unconnected ontology elements')
      end

      it 'have correct code' do
        expect(element.code).to eq(4)
      end

      it 'have correct affects' do
        expect(element.affects).
          to eq(['http://sweet.jpl.nasa.gov/1.1/sunrealm.owl#SunRealm'])
      end
    end

  end

  def do_request(cassette, options)
    VCR.use_cassette 'oops/#{cassette}', match_requests_on: [:body] do
      Oops::Client.request(options)
    end
  end
end
