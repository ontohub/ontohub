module Sentence::Readability
  extend ActiveSupport::Concern

  def set_display_text!
    new_text = self.text.dup

    self.entities.each do |entity|
      unless entity.display_name.nil?
        new_text.gsub!(entity.iri, entity.display_name)
      end
    end

    new_text.gsub!(/\s+/, ' ')

    self.display_text = new_text
    save!
  end
end
