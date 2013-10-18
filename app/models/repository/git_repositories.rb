module Repository::GitRepositories
  extend ActiveSupport::Concern

  included do
    after_create  :git
    after_destroy :destroy_git
  end

  def git(reset=false)
    @git ||= GitRepository.new(local_path)
  end

  def git!
    @git = GitRepository.new(local_path)
  end

  def local_path
    "#{Ontohub::Application.config.git_root}/#{id}"
  end

  def local_path_working_copy
    "#{Ontohub::Application.config.git_working_copies_root}/#{id}"
  end

  def destroy_git
    FileUtils.rmtree local_path
    FileUtils.rmtree local_path_working_copy
  end

  def empty?
    git.empty?
  end

  def is_head?(commit_oid=nil)
    git.is_head?(commit_oid)
  end

  def save_file(tmp_file, filepath, message, user, iri=nil)
    version = nil

    git.add_file({email: user[:email], name: user[:name]}, tmp_file, filepath, message) do |commit_oid|
      version = save_ontology(commit_oid, filepath, user, iri)
    end
    touch
    version
  end

  def save_ontology(commit_oid, filepath, user, iri=nil)
    basepath = File.real_basepath(filepath)
    o = ontologies.where(basepath: basepath).first

    if o
      unless o.versions.find_by_commit_oid(commit_oid)
        # update existing ontology
        version = o.versions.build({ :commit_oid => commit_oid, :user => user }, { without_protection: true })
        o.ontology_version = version
        o.save!
      end
    else
      # create new ontology
      clazz      = %w{.dol .casl}.include?(File.extname(filepath)) ? DistributedOntology : SingleOntology
      o          = clazz.new
      o.basepath = basepath
      o.file_extension = File.extname(filepath)

      o.iri  = iri || "http://#{Settings.hostname}/#{path}/#{basepath}"
      o.name = filepath.split('/')[-1].split(".")[0].capitalize

      o.repository = self
      o.save!
      version = o.versions.build({ :commit_oid => commit_oid, :user => user }, { without_protection: true })
      version.save!
      o.ontology_version = version
      o.save!
    end

    version
  end

  def path_exists?(path, commit_oid=nil)
    path ||= '/'
    git.path_exists?(path, commit_oid)
  end

  def path_info(path=nil, commit_oid=nil)
    path ||= '/'

    if git.empty?
      return { type: :dir, entries: [] }
    end

    if path_exists?(path, commit_oid)
      file = git.get_file(path, commit_oid)
      if file
        {
          type: :file,
          file: file
        }
      else
        entries = list_folder(path, commit_oid)
        entries.each do |name, es|
          es.each do |e|
            o = ontologies.find_by_basepath(File.real_basepath(e[:path]))
            e[:ontology] = o
          end
        end
        {
          type: :dir,
          entries: entries
        }
      end
    else
      file = path.split('/')[-1]
      path = path.split('/')[0..-2].join('/')

      entries = git.folder_contents(commit_oid, path).select { |e| e[:name].split('.')[0] == file }

      case
      when entries.empty?
        nil
      when entries.size == 1
        {
          type: :file_base,
          entry: entries[0],
        }
      else
        {
          type: :file_base_ambiguous,
          entries: entries
        }
      end
    end
  end

  def read_file(filepath, commit_oid=nil)
    git.get_file(filepath, commit_oid)
  end

  # given a commit oid or a branch name, commit_id returns a hash of oid and branch name if existent
  def commit_id(oid)
    return { oid: git.head_oid, branch_name: 'master' } if oid.nil?
    if oid.match /[0-9a-fA-F]{40}/
      branch_names = git.branches.select { |b| b[:oid] == oid }
      if branch_names.empty?
        { oid: oid, branch_name: nil }
      else
        { oid: oid, branch_name: branch_names[0][:name] }
      end
    else
      if git.branch_oid(oid).nil?
        nil
      else
        { oid: git.branch_oid(oid), branch_name: oid }
      end
    end
  end

  def entries_info(oid=nil, path=nil)
    dirpath = git.get_path_of_dir(oid, path)
    git.entries_info(oid,dirpath)
  end

  def changed_files(oid=nil)
    git.changed_files(commit_id(oid)[:oid])
  end

  def recent_changes
    commits(limit: 3)
  end

  # recognized options: :start_oid (first commit to show)
  #                     :stop_oid (first commit to hide)
  #                     :path (file to show changes for)
  #                     :limit (max number of commits)
  def commits(options={}, &block)
    git.commits(options, &block)
  end

  def suspended_save_ontologies(user, options={})
    commits(options) { |commit_oid|
      git.changed_files(commit_oid).each { |f|
        if f[:type] == :add || f[:type] == :change
          save_ontology(commit_oid, f[:path], user)
        end
      }
    }
  end

  # saves all ontologies at the current state in the database
  def save_current_ontologies(user)
    git.files do |filepath, commit_oid|
      save_ontology(commit_oid, filepath, user)
    end
  end

end
