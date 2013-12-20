# enforce eager-loading of parsing classes
Dir.glob(Rails.root + 'lib/parsing_callback/*.rb').each do |file|
  require file
end

module ParsingCallback

  def self.determine_for(ontology)
    logic_name = ontology.logic.to_s
    self.constants.each do |constant|
      moddule = self.const_get(constant)
      if moddule.class == Module
        if moddule.defined_for?(logic_name)
          return moddule.const_get(:Callback).new(ontology)
        end
      end
    end
    GenericCallback.new(ontology)
  end

end
