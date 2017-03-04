require_relative 'direct_hets_generator.rb'

module FixturesGeneration
  class ProofGenerator < DirectHetsGenerator
    protected

    def perform(file)
      header = {'Content-Type' => 'application/json'}
      data = {format: 'json', include: 'false'}
      call_hets(file, 'prove', method: :post, header: header, data: data)
    end

    def files
      all_files_beneath('spec/fixtures/ontologies/prove')
    end

    def subdir
      'prove'
    end
  end
end
