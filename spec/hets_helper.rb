# In this file, 'ontology_fixture' is always the path to the ontology file
# relative to Rails.root.join('spec/fixtures/ontologies/')

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
  evaluator = Hets::DG::Evaluator.new(user, ontology, io: io)
  evaluator.import
  io.close unless io.closed?
end

def parse_ontology(user, ontology, ontology_fixture)
  io = StringIO.new(hets_out_body_ontology(ontology_fixture))
  parse_ontology_hets_out(user, ontology, io)
end
