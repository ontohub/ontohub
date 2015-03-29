class Combination < FakeRecord
  DEFAULT_NAME = 'combinations.dol'

  attr_reader :nodes
  attr_reader :target_repository, :error

  def initialize(target_repository, combination_hash)
    @target_repository = target_repository
    from_combination_hash(combination_hash)
  end

  def save!
    ontology
  rescue StandardError => error
    @error = error
    raise RecordNotSavedError, "Couldn't create combination!"
  end

  def file_name
    @file_name ||= DEFAULT_NAME
  end

  def commit_message
    @commit_message ||= commit_message_erb.result(binding)
  end

  def combination_name
    "combination"
  end

  def ontology
    @ontology ||= create_ontology!
  end

  private
  def from_combination_hash(hash)
    @nodes = hash.fetch(:nodes, [])
    @file_name = hash[:file_name]
    @commit_message = hash[:commit_message]
  end

  def create_ontology!
    repository_file = build_repository_file
    repository_file.save!
    target_repository.ontologies.
      with_path(repository_file.target_path).
      without_parent.first
  end

  def build_repository_file
    target_directory = File.dirname(file_name)
    target_directory = nil if target_directory == '.'
    target_filename = File.basename(file_name)
    file = RepositoryFile.new \
      temp_file: dol_tempfile,
      target_directory: target_directory,
      target_filename: target_filename,
      repository_id: target_repository.path,
      repository_file: {repository_id: target_repository.path},
      user: User.first,
      message: commit_message
  end

  def named_nodes
    nodes.map do |node|
      [node.split('/').last.split('?').first, node]
    end
  end

  def dol_tempfile
    file = Tempfile.new(file_name)
    file.write(dol_representation_erb.result(binding))
    file.rewind
    file
  end

  def dol_representation_erb
    template_file = Rails.root.join('lib/combinations/dol.erb')
    ERB.new(template_file.read, nil, '<>')
  end

  def commit_message_erb
    template_file = Rails.root.join('lib/combinations/commit_message.erb')
    ERB.new(template_file.read, nil, '>')
  end
end
