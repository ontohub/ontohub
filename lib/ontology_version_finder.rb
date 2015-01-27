class OntologyVersionFinder
  attr_accessor :reference, :ontology

  def self.applicable_reference?(reference)
    new(reference, nil).applicable?
  end

  def initialize(reference, ontology)
    self.reference = reference
    self.ontology = ontology
  end

  def find
    OntologyVersion.where(ontology_id: ontology,
                          number: version_reference).first
  end

  def applicable?
    !! version_reference
  end

  def version_reference
    if reference =~ /\A\d+\Z/
      reference.to_i
    end
  end
end
