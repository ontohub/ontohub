require Rails.root.join('spec', 'support', 'json_schema_matcher.rb')

# We use the develop branch to allow unmerged pull requests to be considered.
SCHEMA_BASE_URL = "https://raw.githubusercontent.com/ontohub/ontohub-api-json/develop/"

def url_for(resource, *args, &block)
  request.env['action_controller.instance'].
    send(:url_for, *[resource, *args], &block)
end

def fixture_file(path)
  fixture_path = Rails.root.join('spec/fixtures/')
  fixture_path.join(path)
end

def prover_output_fixture(node, prover)
  generated = fixture_file('').join('prover_output', 'generated', node, prover)
  if File.exist?(generated)
    generated
  else
    $stderr.
      puts("Generated prover output fixture for #{node}, #{prover} not found.")
    $stderr.puts 'Using (possibly outdated) fallback.'
    fixture_file('').join('prover_output', node, prover)
  end
end

def ontology_file(path, ext=nil)
  portion =
    if ext
      "#{path}.#{ext}"
    elsif path.include?('.')
      path
    else
      "#{path}.#{path.to_s.split('/').first}"
    end
  fixture_file("ontologies/#{portion}")
end

def add_fixture_file(repository, relative_file)
  path = ontology_file(relative_file)
  version_for_file(repository, path)
end

def version_for_file(repository, path)
  dummy_user = FactoryGirl.create :user
  basename = File.basename(path)
  version = repository.save_file path, basename, "#{basename} added", dummy_user
end

def setup_pipeline_generator
  stub_fqdn_and_port_for_pipeline_generator
  stub_hets_instance_url_for_pipeline_generator
end

def stub_fqdn_and_port_for_pipeline_generator
  before do
    fqdn = FixturesGeneration::PipelineGenerator::RAILS_SERVER_TEST_FQDN
    port = FixturesGeneration::PipelineGenerator::RAILS_SERVER_TEST_PORT

    allow(Ontohub::Application.config).to receive(:fqdn).and_return(fqdn)
    allow(Ontohub::Application.config).to receive(:port).and_return(port)
  end
end

def stub_hets_instance_url_for_pipeline_generator
  before do
    allow_any_instance_of(HetsInstance).to receive(:uri).
      and_return('http://localhost:8000')
  end
end

def schema_for(name)
  "#{SCHEMA_BASE_URL}#{name}.json"
end

def schema_for_command(command, method = :get, response_code = nil)
  if response_code
    "#{SCHEMA_BASE_URL}#{command}/#{method.to_s.upcase}/#{response_code}.json"
  else
    "#{SCHEMA_BASE_URL}#{command}/#{method.to_s.upcase}/request.json"
  end
end

# includes the convenience-method `define_ontology('name')`
include OntologyUnited::Convenience
