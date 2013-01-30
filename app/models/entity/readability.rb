module Entity::Readability
  extend ActiveSupport::Concern
  
  included do
    after_create :strip_fragment, if: :text_contains_iri
    
    def strip_fragment
      self.fragment_name = URI.parse(text_contains_iri).fragment
    end
    
    def text_contains_iri
      text[URI::regexp(ALLOWED_URI_SCHEMAS)]
    end
  end
end