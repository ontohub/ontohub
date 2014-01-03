module OntologyVersion::Parsing
  extend ActiveSupport::Concern
  
  included do
    @queue = 'hets'
    
    after_create :async_parse, :if => :commit_oid?
  end

  def do_not_parse!
    @deactivate_parsing = true
  end

  def async_parse
    if !@deactivate_parsing
      update_state! :pending
      async :parse
    end
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
      
      @path = Hets.parse(self.raw_path!, self.ontology.repository.url_maps, File.dirname(self.xml_path))
      
      # move generated file to destination
      File.rename @path, self.xml_path

      # Import version
      self.ontology.import_version self, self.user
      
      update_state! :done
    end
  end
  
end
