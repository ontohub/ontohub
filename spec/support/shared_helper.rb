elasticsearch_port = ENV['ELASTIC_TEST_PORT'].present? ? ENV['ELASTIC_TEST_PORT'] : '9250'
Elasticsearch::Model.client = Elasticsearch::Client.new host: "localhost:#{elasticsearch_port}"

# Recording HTTP Requests
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_request do |request|
    # ignore elasticsearch requests
    URI(request.uri).host == 'localhost' &&
    URI(request.uri).port == elasticsearch_port.to_i
  end
  c.register_request_matcher :hets_prove_uri do |request1, request2|
    hets_prove_matcher(request1, request2)
  end
end
