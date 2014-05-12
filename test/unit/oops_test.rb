require 'test_helper'

class OopsTest < ActiveSupport::TestCase

  context 'doing a oops request' do
    context 'with invalid url' do
      should 'raise error' do
        begin
          do_request :invalid, :url => "http://example.com/"
          assert false, "no error was thrown"
        rescue Oops::Error => e
          assert_match(/reach ontohub/, e.message)
        end
      end
    end

    context 'with valid url' do
      setup do
        @result = do_request :valid, :url => "http://sweet.jpl.nasa.gov/1.1/sunrealm.owl"
      end

      should 'return a list' do
        assert_equal 5, @result.count
      end
    end
  end

  context 'parsing a oops response' do
    setup do
      @result = Oops::Response.parse File.read("#{Rails.root}/test/fixtures/oops/sunrealm.xml")
    end

    should 'return correct amount of elements' do
      assert_equal 5, @result.count
    end

    context 'first element responded' do
      setup do
        @element = @result.first
      end

      should 'have correct type' do
        assert_equal 'Pitfall', @element.type
      end

      should 'have correct name' do
        assert_equal 'Creating unconnected ontology elements', @element.name
      end

      should 'have correct code' do
        assert_equal 4, @element.code
      end

      should 'have correct affects' do
        assert_equal ['http://sweet.jpl.nasa.gov/1.1/sunrealm.owl#SunRealm'], @element.affects
      end
    end

  end

  def do_request(cassette, options)
    VCR.use_cassette "oops/#{cassette}", match_requests_on: [:body] do
      Oops::Client.request(options)
    end
  end

end
