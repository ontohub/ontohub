require 'test_helper'

class OopsTest < ActiveSupport::TestCase
  
  context 'doing a oops request' do
    context 'with invalid url' do
      should 'raise error' do
        begin
          do_request :invalid, "http://example.com/"
          assert false, "no error was thrown"
        rescue Oops::Error => e
          assert_match(/expected XML/, e.message)
        end
      end
    end
    
    context 'with valid url' do
      setup do
        do_request :valid, "http://sweet.jpl.nasa.gov/1.1/sunrealm.owl"
      end
      
      should 'return body' do
        puts @response
      end
    end
  end
  
  def do_request(cassette, url)
    VCR.use_cassette "oops/#{cassette}", match_requests_on: [:body] do
      @response = Oops::Client.request(url)
    end
  end
  
end
