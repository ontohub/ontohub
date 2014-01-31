module OntologyVersion::Parsing
  extend ActiveSupport::Concern
  
  included do
    @queue = 'hets'
    
    after_create :async_parse, :if => :commit_oid?
  end

  def do_not_parse!
    @deactivate_parsing = true
  end

  def async_parse(*args)
    if !@deactivate_parsing
      update_state! :pending
      async :parse, *args
    end
  end

  def parse(refresh_cache: false)
#    do_or_set_failed do
#      condition = ['checksum = ? and id != ?', self.checksum, self.id]
#      if OntologyVersion.where(condition).any?
#        raise Exception.new('Another file with same checksum already exists.')
#      end
#    end

    update_state! :processing

    do_or_set_failed do
      refresh_checksum! unless checksum?
      
      # run hets if necessary
      generate_xml if refresh_cache || !xml_file?

      # Import version
      self.ontology.import_version self, self.user
      
      update_state! :done
    end
  end

  # generate XML by passing the raw ontology to Hets
  def generate_xml
    path = Hets.parse(raw_path!, ontology.repository.url_maps, File.dirname(xml_path))
    
    # move generated file to destination
    File.rename path, xml_path
  end
  
end
