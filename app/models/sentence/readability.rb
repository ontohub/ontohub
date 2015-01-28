module Sentence::Readability
  extend ActiveSupport::Concern

  def set_display_text!
    if text
      self.display_text = text.dup

      symbols.each do |symbol|
        if symbol.display_name && symbol.iri
          display_text.gsub!(symbol.iri, symbol.display_name)
        end
      end

      display_text.gsub!(/\s+/, ' ')

      save!
    end
  end
end
