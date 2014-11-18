module Sentence::Readability
  extend ActiveSupport::Concern

  def set_display_text!
    if text
      self.display_text = text.dup

      entities.each do |entity|
        if entity.display_name && entity.iri
          display_text.gsub!(entity.iri, entity.display_name)
        end
      end

      display_text.gsub!(/\s+/, ' ')

      save!
    end
  end
end
