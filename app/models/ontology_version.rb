class OntologyVersion < ActiveRecord::Base
  @queue = :hets

  belongs_to :user
  belongs_to :ontology

  mount_uploader :raw_file, OntologyUploader
  mount_uploader :xml_file, OntologyUploader

  attr_accessible :raw_file, :source_uri

  validates_format_of :source_uri,
    :with => URI::regexp(%w(http https file gopher)),
    :if => :source_uri?

  validate :validates_file_or_source_uri

  validate :validates_size_of_raw_file, :if => :raw_file?

  def parse
    raise ArgumentError.new('No raw_file set.') unless raw_file?

    do_or_set_failed do
      @path = Hets.parse(self.raw_file.current_path)
    end

    self.xml_file = File.open(@path)
    save!

    do_or_set_failed do
      self.ontology.import_latest_version
    end

    File.delete(@path)

    update_state! :done
  end

protected

  def validates_file_or_source_uri
    if source_uri? and raw_file?
      errors.add :source_uri, 'Specify source URI OR file.'
    end
  end

  def validates_size_of_raw_file
    if raw_file.size > 10.megabytes.to_i
      errors.add :raw_file, 'Maximum upload size is 10M.'
    end
  end

  def do_or_set_failed(&block)
    raise ArgumentError.new('No block given.') unless block_given?

    begin
      yield
    rescue Exception => e
      update_state! :failed, e.message
      raise e
    end
  end

  def update_state!(state, error_message = nil)
    ontology.state = state.to_s
    ontology.save!

    self.last_error = error_message
    save!
  end
end
