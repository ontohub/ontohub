module OntologyVersion::Parsing
  extend ActiveSupport::Concern
  
  included do
    @queue = 'hets'
    
    after_create :async_parse, :if => :commit_oid?
    attr_accessor :fast_parse
  end

  def do_not_parse!
    @deactivate_parsing = true
  end

  def async_parse
    if !@deactivate_parsing
      update_state! :pending

      if @fast_parse
        async :parse_fast
      else
        async :parse_full
      end
    end
  end

  def parse(structure_only: false)
#    do_or_set_failed do
#      condition = ['checksum = ? and id != ?', self.checksum, self.id]
#      if OntologyVersion.where(condition).any?
#        raise Exception.new('Another file with same checksum already exists.')
#      end
#    end

    update_state! :processing

    do_or_set_failed do
      refresh_checksum! unless checksum?
      
      @path = Hets.parse(self.raw_path!, self.ontology.repository.url_maps, File.dirname(self.xml_path), structure_only: false)
      
      # move generated file to destination
      File.rename @path, self.xml_path

      # Import version
      self.ontology.import_version self, self.user
      
      update_state! :done
    end
  end
  
  def parse_full
    parse(structure_only: false)
  end

  def parse_fast
    parse(structure_only: true)
  end
end
