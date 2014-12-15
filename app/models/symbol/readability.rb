module Symbol::Readability
  extend ActiveSupport::Concern

  included do
    before_save :set_display_name_and_iri
  end

  def set_display_name_and_iri
    name_iri = URI.parse(name_is_iri_and_in_text) if name_is_iri_and_in_text
    if name_iri
      self.display_name = name_iri.fragment || name_iri.path.split("/").last
      self.iri = name_iri.to_s
      self.display_name.gsub!(/_/, ' ')
    else
      self.display_name = name
    end
    set_obo_display_name_if_applicable
  end

  def name_is_iri_and_in_text
    self.text[self.name][URI::regexp(Settings.allowed_iri_schemes)]
  rescue StandardError
    false
  end

  def set_obo_display_name_if_applicable
    if ontology.file_extension == '.obo' && label
      self.display_name = label
    end
  end
end
