module OntologyVersion::Parsing
  extend ActiveSupport::Concern
  
  included do
    @queue = :hets
    after_create :parse_async
  end

  def parse
    raise ArgumentError.new('No raw_file set.') unless raw_file?

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
  
protected
  
  def do_or_set_failed(&block)
    raise ArgumentError.new('No block given.') unless block_given?

    begin
      yield
    rescue Exception => e
      update_state! :failed, e.message
      raise e
    end
  end

  def update_state!(state, error_message = nil)
    ontology.state = state.to_s
    ontology.save!

    self.last_error = error_message
    save!
  end
end
