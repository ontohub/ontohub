module Ontology::FileExtensions
  extend ActiveSupport::Concern

  module ClassMethods
    include GraphStructures::SqlHelper
    def file_extensions
      @file_extensions ||= file_extensions_distributed + file_extensions_single
    end

    def file_extensions_distributed
      @file_extensions_distributed ||= pluck_select(
        'SELECT extension FROM ontology_file_extensions WHERE distributed = \'true\'', :extension)
    end

    def file_extensions_single
     @file_extensions_single ||= pluck_select(
        'SELECT extension FROM ontology_file_extensions WHERE distributed = \'false\'', :extension)
    end
  end

end
