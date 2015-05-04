class Combination < FakeRecord
  DEFAULT_NAME = 'combinations.dol'
  DEFAULT_COMBINATION_NAME = 'combination'

  attr_reader :nodes
  attr_reader :target_repository, :error, :user

  validate :nodes_is_collection, :nodes_is_not_empty

  def self.combined_ontology!(*args)
    create!(*args).ontology
  end

  def self.create!(*args)
    combination = new(*args)
    combination.save!
    combination
  end

  def initialize(user, target_repository, combination_hash)
    @user = User.find(user)
    @target_repository = Repository.find(target_repository)
    from_combination_hash(combination_hash.with_indifferent_access)
  end

  def save!
    raise RecordNotSavedError unless valid?
    ontology
  end

  def file_name
    @file_name ||= DEFAULT_NAME
  end

  def commit_message
    @commit_message ||= commit_message_erb.result(binding)
  end

  def combination_name
    @combination_name ||= DEFAULT_COMBINATION_NAME
  end

  def ontology
    @ontology ||= create_ontology!
  end

  private
  def from_combination_hash(hash)
    @nodes = hash.fetch(:nodes, [])
    @file_name = hash[:file_name]
    @commit_message = hash[:commit_message]
    @combination_name = hash[:combination_name]
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
      user: user,
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

  def nodes_is_collection
    unless nodes.is_a?(Enumerable)
      errors.add(:nodes, 'is not an array/collection')
    end
  end

  def nodes_is_not_empty
    unless nodes.present?
      errors.add(:nodes, 'should be set and contain URIs')
    end
  end
end
