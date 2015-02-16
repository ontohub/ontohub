class OntologyVersionFinder
  SUPPORTED_BRANCHES = %w(master)

  attr_accessor :reference, :ontology

  def self.applicable_reference?(reference)
    new(reference, nil).applicable?
  end

  def initialize(reference, ontology)
    self.reference = reference
    self.ontology = ontology
  end

  def find
    with_version_reference ||
      with_commit_reference ||
      with_branch_reference
  end

  def with_version_reference
    OntologyVersion.where(ontology_id: ontology,
                          number: version_reference).first
  end

  def with_commit_reference
    OntologyVersion.where(ontology_id: ontology,
                          commit_oid: commit_reference).first
  end

  def with_date_reference
    OntologyVersion.joins(:commit).where(ontology_id: ontology).
      where('commits.author_date <= ?', end_of_day(date_reference)).
      order('commits.author_date DESC').first
  end

  def with_branch_reference
    branch_commit = ontology.repository.commit_id(branch_reference)[:oid]
    OntologyVersion.where(ontology_id: ontology,
                          commit_oid: branch_commit).first
  end

  def applicable?
    result = version_reference ||
      commit_reference ||
      date_reference ||
      branch_reference
    !! result
  end

  def version_reference
    if reference =~ /\A\d+\Z/
      reference.to_i
    end
  end

  def commit_reference
    if reference =~ /\A[a-fA-F0-9]+\Z/
      reference
    end
  end

  def date_reference
    if reference =~ /\A\d{4}-\d{2}-\d{2}\Z/
      reference
    end
  end

  def branch_reference
    if SUPPORTED_BRANCHES.include?(reference)
      reference
    end
  end

  def end_of_day(date_reference)
    "#{date_reference} 23:59:59"
  end
end
