module OntologyVersion::Files
  extend ActiveSupport::Concern
  
  included do
    # virtual attribute for upload
    attr_accessible :raw_file
  end

  def raw_file=(value)
    @raw_file = value
  end
  
end