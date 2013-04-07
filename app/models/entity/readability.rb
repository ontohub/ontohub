module Entity::Readability
  extend ActiveSupport::Concern
  
  included do
    before_save :set_display_name_and_iri, if: :name_is_iri_and_in_text
  end
  
  def set_display_name_and_iri
    iri = URI.parse(name_is_iri_and_in_text)
    self.display_name = iri.fragment || iri.path.split("/").last
    self.iri = iri.to_s
  end
  
  def name_is_iri_and_in_text
    self.text[self.name][URI::regexp(ALLOWED_URI_SCHEMAS)] rescue ""
  end
  
end
