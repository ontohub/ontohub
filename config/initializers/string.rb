# Extensions to the String class
class String
  # Creates a space-separated sequence of lower-case tokens such as "nice pizza ontology"
  # from a sequence of title-case tokens such as "NicePizzaOntology", "Nice-Pizza-Ontology"
  # or "Nice_Pizza_Ontology".
  def from_titlecase_to_spacedlowercase
    self
      .gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/,'\1 \2')
      .gsub(/([a-z\d])([A-Z])/,'\1 \2')
      .tr('_-', '  ')
      .downcase
  end

  # Selects the string between parentheses
  def between_parentheses
    self.gsub(/^[^(]*[(]([^)]*).*$/, '\1')
  end

  def encoding_utf8
    self.force_encoding('UTF-8').encode('utf-8', 'binary', undef: :replace)
  end
end
