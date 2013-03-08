module Entity::Readability
  extend ActiveSupport::Concern
  
  included do
    before_save :set_display_name_and_iri, if: :text_contains_iri
    
    def set_display_name_and_iri
      iri = URI.parse(text_contains_iri)
      self.display_name = iri.fragment || iri.path.split("/").last
      self.iri = iri.to_s
    end
    
    def text_contains_iri
      text[URI::regexp(ALLOWED_URI_SCHEMAS)]
    end
  end
end
