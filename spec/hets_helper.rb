# In this file, 'ontology_fixture' is always the path to the ontology file
# relative to Rails.root.join('spec/fixtures/ontologies/')

def hets_prove_matcher(request1, request2)
  uri1 = URI(request1.uri)
  uri2 = URI(request2.uri)

  regexp_prove_path = %r{^/prove/(?<escaped_iri>[^/]*)(?<end>.*)$}
  regexp_ontology_path = %r{^/ref/\d+/(?<repo>[^/]+)/(?<ontology>.*)$}

  match1 = uri1.path.match(regexp_prove_path)
  match2 = uri2.path.match(regexp_prove_path)

  return request1.uri == request2.uri unless match1 && match2

  inner_iri1 = URI.unescape(match1[:escaped_iri])
  inner_iri2 = URI.unescape(match2[:escaped_iri])

  inner_match1 = URI(inner_iri1).path.match(regexp_ontology_path)
  inner_match2 = URI(inner_iri2).path.match(regexp_ontology_path)

  return request1.uri == request2.uri unless inner_match1 && inner_match2

  match1[:end] == match2[:end] &&
  inner_match1[:ontology] == inner_match2[:ontology] &&

  query1 = uri1.query.sub(/hets-libdirs=.*?(%3B|;|%26|&)/i, '')
  query2 = uri2.query.sub(/hets-libdirs=.*?(%3B|;|%26|&)/i, '')
  return false unless query1 == query2

  # We don't check for the port because the HetsInstances factory varies it.
  %i(scheme host fragment).all? { |m| uri1.send(m) == uri2.send(m)}
end

def hets_vcr_file(subdir, ontology_fixture)
  # Replace last occurence of '.' by '_' in the filepath (VCR convention).
  portions = ontology_fixture.split('.')
  path = portions[0..-2].join('.')
  extension = portions[-1]

  fixture_file(File.join('vcr', 'hets-out', subdir, "#{path}_#{extension}.yml"))
end

def hets_ontology_vcr_file(ontology_fixture)
  hets_vcr_file('dg', ontology_fixture)
end

def hets_proof_vcr_file(ontology_fixture)
  hets_vcr_file('proof', ontology_fixture)
end

def hets_provers_vcr_file(ontology_fixture)
  hets_vcr_file('provers', ontology_fixture)
end


def hets_out_body(subdir, ontology_fixture)
  yaml = YAML.load(File.open(hets_vcr_file(subdir, ontology_fixture)))
  yaml['http_interactions'].first['response']['body']['string']
end

def hets_out_body_ontology(ontology_fixture)
  hets_out_body('dg', ontology_fixture)
end

def hets_out_body_proof(ontology_fixture)
  hets_out_body('proof', ontology_fixture)
end

def hets_out_body_provers(ontology_fixture)
  hets_out_body('provers', ontology_fixture)
end


def parse_ontology_hets_out(user, ontology, io, provers_io)
  current_version = ontology.current_version
  allow(Hets).to receive(:parse_via_api).and_return(io)
  allow(Hets).to receive(:provers_via_api) do
    provers_io.rewind
    provers_io
  end
  allow(current_version).to receive(:ontology).and_return(ontology)
  allow(ontology).to receive(:import_version) do
    evaluator = Hets::DG::Importer.new(user, ontology, io: io,
                                       version: ontology.current_version)
    evaluator.import
  end

  current_version.parse
  io.close unless io.closed?
  provers_io.close unless provers_io.closed?

  allow(Hets).to receive(:parse_via_api).and_call_original
  allow(Hets).to receive(:provers_via_api).and_call_original
end

def parse_ontology(user, ontology, ontology_fixture, provers_io = nil)
  io = StringIO.new(hets_out_body_ontology(ontology_fixture))
  provers_io = StringIO.new(hets_out_body_provers(ontology_fixture))
  parse_ontology_hets_out(user, ontology, io, provers_io)
end


def setup_hets
  let(:hets_instance) { create_local_hets_instance }
  before do
    stub_request(:get, %r{http://localhost:8\d{3}/version}).
      to_return(body: Hets.minimal_version_string)
    hets_instance
  end
  after { hets_instance.finish_work! }
end

def stub_hets_for(ontology_fixture,
                  command: 'dg', with: nil, with_version: nil, method: :get)
  stub_request(:get, %r{http://localhost:8\d{3}/version}).
    to_return(body: Hets.minimal_version_string)
  stub_request(method, hets_uri(command, with, with_version)).
    to_return(body: hets_out_body(command, ontology_fixture))
  if command == 'dg'
    stub_request(method, hets_uri('provers', with, with_version)).
      to_return(body: hets_out_body('provers', ontology_fixture))
  end
end

def create_local_hets_instance
  Sidekiq::Testing.fake! { FactoryGirl.create(:local_hets_instance) }
end

def hets_uri(command = 'dg', portion = nil, version = nil)
  hets_instance =
    begin
      HetsInstance.choose!
    rescue HetsInstance::NoRegisteredHetsInstanceError
      create_local_hets_instance
      HetsInstance.choose!
    end
  specific = ''
  # %2F is percent-encoding for forward slash /
  specific << "ref%2F#{version}.*" if version
  specific << "#{portion}.*" if portion
  return %r{#{hets_instance.uri}/#{command}/.*#{specific}}
end
