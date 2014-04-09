module Ontology::FileExtensions
  extend ActiveSupport::Concern

  included do
    def self.file_extensions
      @file_extensions ||= file_extensions_distributed + file_extensions_single
    end

    def self.file_extensions_distributed
      @file_extensions_distributed ||= ActiveRecord::Base.connection.execute(
        "SELECT extension FROM ontology_file_extensions WHERE distributed = 'true'").map{ |r| r['extension']}
    end

    def self.file_extensions_single
     @file_extensions_single ||= ActiveRecord::Base.connection.execute(
      "SELECT extension FROM ontology_file_extensions WHERE distributed = 'false'"
      ).map{ |r| r['extension']}
    end
  end

end
