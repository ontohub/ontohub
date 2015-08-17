def handle_error(e, reason)
  puts <<-MSG.squish
    Could not seed "oops" because #{reason}.
    #{e.class}: #{e.message}
    Continuing with other data.
  MSG
end

def call_oops
  # Add OOPS! requests and responses to pizza ontology.
  ontology = Ontology.where(name: "Pizza").first!
  version  = ontology.versions.first
  begin
    if version
      request  = version.build_request({state: 'done'}, without_protection: true)
      request.save!

      responses = %w(Pitfall Warning Warning Suggestion).map do |type|
        request.responses.create! \
        name:         Faker::Name.name,
        code:         0,
        description:  Faker::Lorem.paragraph,
        element_type: type
      end
    end
    ontology.symbols.all.select do |symbol|
      symbol.oops_responses = responses.sample(rand(responses.count))
    end
  rescue SocketError => e
    handle_error(e, 'you are offline')
  rescue RestClient::Exception => e
    handle_error(e, 'of a client error')
  end
end

if Rails.env.test?
  VCR.use_cassette('seeds/oops') do
    call_oops
  end
else
  call_oops
end
