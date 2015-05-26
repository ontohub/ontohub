class OntologyVersionFinder
  SUPPORTED_BRANCHES = %w(master)
  REF_RE = %r{\A/?ref/([^/]+)(/[^?]+).*\Z}

  attr_accessor :ontology, :reference

  def self.applicable_reference?(reference, repository)
    new(reference, repository: repository).applicable?
  end

  def self.find(path)
    res = path.match(REF_RE)
    new(res[1], ontology: Ontology.find_with_locid(res[2])).find if res
  end

  def initialize(reference, ontology: nil, repository: ontology.repository)
    self.reference = reference
    self.ontology = ontology
    self.commit_reference = CommitReference.new(repository, reference)
  end

  def find
    if ontology
      with_version_reference ||
        with_commit_reference ||
        with_branch_reference
    end
  end

  def with_version_reference
    OntologyVersion.where(ontology_id: ontology,
                          number: version_reference).first
  end

  def with_commit_reference
    OntologyVersion.where(ontology_id: ontology,
                          commit_oid: commit_reference.commit_oid).first
  end

  def with_date_reference
    OntologyVersion.joins(:commit).where(ontology_id: ontology).
      where('commits.author_date <= ?', commit_reference.commit.author_date).
      order('commits.author_date DESC').first
  end

  def with_branch_reference
    OntologyVersion.where(ontology_id: ontology,
                          commit_oid: commit_reference.commit_oid).first
  end

  def applicable?
    result = version_reference ||
      commit_reference.commit_oid? ||
      commit_reference.date? ||
      commit_reference.branch?
    !! result
  end

  def version_reference
    if reference =~ /\A\d+\Z/
      reference.to_i
    end
  end
end
