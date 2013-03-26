module Sentence::Readability
  extend ActiveSupport::Concern
  
  included do
    before_save :set_display_text, if: :entities_are_found
    
    def set_display_text
      new_text = self.text
      self.entities.each do |entity|
        new_text = new_text.gsub!(entity.iri, entity.display_name)
      end
      self.display_text = new_text
    end
    
    def entities_are_found
      self.entities.where('display_name is not null').size > 0
    end
  end
end
