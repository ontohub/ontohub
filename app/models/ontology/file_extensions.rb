module Ontology::FileExtensions
  extend ActiveSupport::Concern

  included do
    FILE_EXTENSIONS_DISTRIBUTED = ActiveRecord::Base.connection.execute(
        "SELECT extension FROM ontology_file_extensions WHERE distributed = 'true'"
      ).map{ |r| r['extension']}
    FILE_EXTENSIONS_SINGLE = ActiveRecord::Base.connection.execute(
      "SELECT extension FROM ontology_file_extensions WHERE distributed = 'false'"
      ).map{ |r| r['extension']}
    FILE_EXTENSIONS = FILE_EXTENSIONS_DISTRIBUTED + FILE_EXTENSIONS_SINGLE
  end

end
