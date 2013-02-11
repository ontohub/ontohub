module Entity::Readability
  extend ActiveSupport::Concern
  
  included do
    after_create :set_display_name, if: :text_contains_iri
    
    def set_display_name
      uri = URI.parse(text_contains_iri)
      self.display_name = uri.fragment || uri.path.split("/").last
      save!
    end
    
    def text_contains_iri
      text[URI::regexp(ALLOWED_URI_SCHEMAS)]
    end
  end
end
