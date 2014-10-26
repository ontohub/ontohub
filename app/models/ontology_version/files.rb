module OntologyVersion::Files
  extend ActiveSupport::Concern

  included do
    # virtual attribute for upload
    attr_accessible :raw_file
    before_create :commit_raw_file, unless: :commit_oid?
  end

  def raw_file=(value)
    @raw_file = value
  end

  def commit_raw_file
    return true if ontology.parent
    raise "raw file missing" unless @raw_file
    self.path = @raw_file.original_filename if self.path.nil?
    # otherwise the file upload is broken (no implicit conversion of ActionDispatch::Http::UploadedFile into String):
    tmp_file = if @raw_file.class == ActionDispatch::Http::UploadedFile
        @raw_file.tempfile
      else
        @raw_file
      end
    repository.save_file(tmp_file, self.path, "message", user)
  end

  def tmp_dir
    Ontohub::Application.config.commits_path.join(commit_oid)
  end

  # path to the raw file
  def raw_path
    tmp_dir.join("raw",self.path)
  end

  # path to the raw file, checks out the raw file if is missing
  def raw_path!
    checkout_raw!
    raw_path
  end

  def raw_file?
    File.exists? raw_path
  end

  # checks out the raw file
  def checkout_raw!
    unless raw_file?
      FileUtils.mkdir_p raw_path.dirname
      File.open(raw_path, "w"){|f| f.write raw_data }
    end
  end

  # returns the raw data directly from the repository
  def raw_data
    repository.get_file(self.path, commit_oid).content.encoding_utf8
  end

end
