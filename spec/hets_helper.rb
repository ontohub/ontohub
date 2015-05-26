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
  %i(scheme host port query fragment).all? { |m| uri1.send(m) == uri2.send(m)}
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


def parse_ontology_hets_out(user, ontology, io)
  evaluator = Hets::DG::Importer.new(user, ontology, io: io)
  evaluator.import
  io.close unless io.closed?
end

def parse_ontology(user, ontology, ontology_fixture)
  io = StringIO.new(hets_out_body_ontology(ontology_fixture))
  parse_ontology_hets_out(user, ontology, io)
end


def setup_hets
  let(:hets_instance) { create(:local_hets_instance) }
  before do
    stub_request(:get, 'http://localhost:8000/version').
      to_return(body: Hets.minimal_version_string)
    hets_instance
  end
end

def stub_hets_for(ontology_fixture,
                  command: 'dg', with: nil, with_version: nil, method: :get)
  stub_request(:get, 'http://localhost:8000/version').
    to_return(body: Hets.minimal_version_string)
  stub_request(method, hets_uri(command, with, with_version)).
    to_return(body: hets_out_body(command, ontology_fixture))
  if command == 'dg'
    stub_request(method, hets_uri('provers', with, with_version)).
      to_return(body: hets_out_body('provers', ontology_fixture))
  end
end

def hets_uri(command = 'dg', portion = nil, version = nil)
  hets_instance = HetsInstance.choose!
rescue HetsInstance::NoRegisteredHetsInstanceError => e
  if hets_instance.nil?
    FactoryGirl.create(:local_hets_instance)
    hets_instance = HetsInstance.choose!
  end
ensure
  specific = ''
  # %2F is percent-encoding for forward slash /
  specific << "ref%2F#{version}.*" if version
  specific << "#{portion}.*" if portion
  return %r{#{hets_instance.uri}/#{command}/.*#{specific}}
end
