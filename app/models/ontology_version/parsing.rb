module OntologyVersion::Parsing
  extend ActiveSupport::Concern
  
  included do
    @queue = :hets
    after_create :parse_async, :if => :raw_file?
  end

  def parse
    raise ArgumentError.new('No raw_file set.') unless raw_file?

    update_state! :processing

    do_or_set_failed do
      @path = Hets.parse(self.raw_file.current_path)

      self.xml_file = File.open(@path)
      save!

      self.ontology.import_latest_version
    end

    update_state! :done
  end
  
  def parse_async
    async :parse
  end
end
