class Combination < FakeRecord
  DEFAULT_NAME = 'combinations.dol'

  attr_reader :nodes
  attr_reader :target_repository

  def initialize(target_repository, combination_hash)
    @target_repository = target_repository
    from_combination_hash(combination_hash)
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

  private
  def from_combination_hash(hash)
    @nodes = hash.fetch(:nodes, [])
    @file_name = hash[:file_name]
    @commit_message = hash[:commit_message]
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
