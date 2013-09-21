module Repository::GitRepositories
  extend ActiveSupport::Concern

  included do
    after_create  :git
    after_destroy :destroy_git
  end

  def git
    @git ||= GitRepository.new(local_path)
  end

  def local_path
    "#{Ontohub::Application.config.git_root}/#{id}"
  end

  def destroy_git
    FileUtils.rmtree local_path
  end

  def save_file(tmp_file, filepath, message, user, iri=nil)
    version = nil

    git.add_file({email: user[:email], name: user[:name]}, tmp_file, filepath, message) do |commit_oid|
      o = ontologies.where(path: filepath).first

      if o
        # update existing ontology
        version = o.versions.build({ :commit_oid => commit_oid, :user => user }, { without_protection: true })
        o.ontology_version = version
        o.save!
      else
        # create new ontology
        clazz  = filepath.ends_with?('.casl') ? DistributedOntology : SingleOntology
        o      = clazz.new
        o.path = filepath

        o.iri  = iri || "http://#{Settings.hostname}/#{path}/#{Ontology.filename_without_extension(filepath)}"
        o.name = filepath.split('/')[-1].split(".")[0].capitalize

        version = o.versions.build({ :commit_oid => commit_oid, :user => user }, { without_protection: true })

        o.repository = self
        o.save!
        o.ontology_version = version;
        o.save!
      end
    end
    touch
    version
  end

  def path_exists?(path, commit_oid=nil)
    path ||= '/'
    git.path_exists?(path, commit_oid=nil)
  end

  def path_type(path=nil, commit_oid=nil)
    path ||= '/'

    if path_exists?(path, commit_oid)
      file = git.get_file(path, commit_oid)
      return {type: :raw, file: file} if file
      return {type: :dir, entries: list_folder(path, commit_oid)}
    end

    file = path.split('/')[-1]
    path = path.split('/')[0..-2].join('/')

    filenames = list_folder(path, commit_oid).select { |e| e[:name].split('.')[0] == file }

    {
      type: :file_base,
      entries: filenames
    }
  end

  def list_folder(folderpath, commit_oid=nil)
    folderpath ||= '/'
    git.folder_contents(commit_oid, folderpath)
  end

  def read_file(filepath, commit_oid=nil)
    git.get_file(filepath, commit_oid)[:content]
  end
end
