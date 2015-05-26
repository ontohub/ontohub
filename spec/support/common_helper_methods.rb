require Rails.root.join('spec', 'support', 'json_schema_matcher.rb')

def controllers_locid_for(resource, *args, &block)
  request.env['action_controller.instance'].
    send(:locid_for, resource, *args, &block)
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
  dummy_user = create :user
  basename = File.basename(path)
  version = repository.save_file path, basename, "#{basename} added", dummy_user
end

def schema_for(name)
  "https://masterthesis.rightsrestricted.com/ontohub/#{name}.json"
end

# includes the convenience-method `define_ontology('name')`
include OntologyUnited::Convenience
