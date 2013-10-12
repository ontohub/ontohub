module OntologyVersion::Parsing
  extend ActiveSupport::Concern
  
  included do
    @queue = 'hets'
    after_create :parse_async, :if => :commit_oid?
  end

  def parse
#    do_or_set_failed do
#      condition = ['checksum = ? and id != ?', self.checksum, self.id]
#      if OntologyVersion.where(condition).any?
#        raise Exception.new('Another file with same checksum already exists.')
#      end
#    end

    update_state! :processing

    do_or_set_failed do
      refresh_checksum! unless checksum?
      
      @path = Hets.parse(self.raw_path!, File.dirname(self.xml_path))
      
      # move generated file to destination
      File.rename @path, self.xml_path

      self.ontology.import_latest_version self.user
      
      update_state! :done
    end
  end
  
  def parse_async
    async :parse
  end
end
