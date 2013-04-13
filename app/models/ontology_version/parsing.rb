module OntologyVersion::Parsing
  extend ActiveSupport::Concern
  
  included do
    after_create :parse_async, :if => :raw_file?
  end

  def parse
    raise ArgumentError.new('No raw_file set.') unless raw_file?

#    do_or_set_failed do
#      condition = ['checksum = ? and id != ?', self.checksum, self.id]
#      if OntologyVersion.where(condition).any?
#        raise Exception.new('Another file with same checksum already exists.')
#      end
#    end

    update_state! :processing

    do_or_set_failed do
      @path = Hets.parse(self.raw_file.current_path)

      self.xml_file = File.open(@path)
      save!

      File.delete(@path)
      self.ontology.import_latest_version self.user
      
      update_state! :done
    end
  end
  
  def parse_async
    async :parse
  end
end
