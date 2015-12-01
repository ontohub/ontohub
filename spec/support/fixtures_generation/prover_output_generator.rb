require_relative 'direct_hets_generator.rb'

module FixturesGeneration
  class ProverOutputGenerator < DirectHetsGenerator
    NODES = %w(CounterSatisfiable Theorem ResourceOut)
    PROVERS = %w(SPASS darwin darwin-non-fd eprover)
    protected

    def perform(file)
      header = {'Content-Type' => 'application/json'}
      data_template = {format: 'json', include: 'true'}
      NODES.each do |node|
        PROVERS.each do |prover|
          data = data_template.merge(prover: prover, node: node)
          response = call_hets(file, 'prove',
                          method: :post, header: header, data: data)
          json = JSON.parse(response.read_body)
          write_prover_output_fixture(node, prover, json)
          response
        end
      end
    end

    def files
      %w(spec/fixtures/ontologies/prove/prover_output_generator.casl)
    end

    def subdir
      'prover_output'
    end

    def write_prover_output_fixture(node, prover, response_hash)
      target_file(node, prover) do |file|
        file.write(response_hash.first['goals'].first['prover_output'])
      end
    end

    def target_file(node, prover, &block)
      filepath = "spec/fixtures/prover_output/generated/#{node}/#{prover}"
      FileUtils.mkdir_p(File.dirname(filepath))
      File.open(filepath, 'w', &block)
    end
  end
end
