module Sentence::Readability
  extend ActiveSupport::Concern
  
  included do
    before_save :set_display_text
   #  before_save :set_display_text, if: :entities_found
  end
    
  def set_display_text
    new_text = self.text
    self.entities.each do |entity|
      p entity
      unless entity.display_name.nil?
        p new_text = new_text.gsub!(entity.iri, entity.display_name)
      end
    end
    self.display_text = new_text
  end
 
  def entities_found
    a = self.entities.where('entities.display_name is not null')
    p a
    a if a.size > 0
  end
end
