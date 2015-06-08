require_relative 'direct_hets_generator.rb'

module FixturesGeneration
  class ProversGenerator < DirectHetsGenerator
    protected

    def perform(file)
      query_string = '?format=json'
      call_hets(file, 'provers', query_string: query_string)
    end

    def files
      all_files_beneath('spec/fixtures/ontologies').select do |file|
        !file.end_with?('.xml')
      end
    end

    def subdir
      'provers'
    end
  end
end
