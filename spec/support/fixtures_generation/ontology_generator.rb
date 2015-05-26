require_relative 'direct_hets_generator.rb'

module FixturesGeneration
  class OntologyGenerator < DirectHetsGenerator
    protected

    def perform(file)
      hets_api_options = "#{HETS_API_OPTIONS}/full-signatures/full-theories"
      call_hets(file, 'dg', hets_api_options: hets_api_options)
    end

    def files
      all_files_beneath('spec/fixtures/ontologies').select do |file|
        !file.end_with?('.xml')
      end
    end

    def subdir
      'dg'
    end
  end
end
