require 'git_repository'

module Repository::GitRepositories
  extend ActiveSupport::Concern

  delegate :dir?, :points_through_file?, to: :git

  included do
    after_create  :create_and_init_git
    after_destroy :destroy_git
  end

  def git
    @git ||= GitRepository.new(local_path.to_s)
  end

  def local_path
    Ontohub::Application.config.git_root.join(id.to_s)
  end

  def create_and_init_git
    git
    symlink_name = local_path.join("hooks")
    symlink_name.rmtree
    symlink_name.make_symlink(Rails.root.join('git','hooks').
      # replace capistrano-style release with 'current'-symlink
      sub(%r{/releases/\d+/}, '/current/'))
  end

  def destroy_git
    git.destroy
  end

  def empty?
    git.empty?
  end

  def is_head?(commit_oid=nil)
    git.is_head?(commit_oid)
  end

  def save_file(tmp_file, filepath, message, user, iri=nil)
    version = nil

    git.add_file({email: user.email, name: user.name}, tmp_file, filepath, message) do |commit_oid|
      version = save_ontology(commit_oid, filepath, user, iri)
    end
    touch
    version
  end

  def save_file_only(tmp_file, filepath, message, user)
    commit = nil
    name = user ? user.name : Settings.fallback_commit_user
    email = user ? user.email : Settings.fallback_commit_email
    git.add_file({email: email, name: name}, tmp_file, filepath, message) do |commit_oid|
      commit = commit_oid
    end
    touch
    commit
  end

  def save_ontology(commit_oid, filepath, user=nil, iri=nil)
    # we expect that this method is only called, when the ontology is 'present'

    return unless Ontology::FILE_EXTENSIONS.include?(File.extname(filepath))
    version = nil
    basepath = File.basepath(filepath)
    o = ontologies.without_parent.where(basepath: basepath).first
    return unless o.nil? || o.path == filepath

    if o
      o.present = true
      unless o.versions.find_by_commit_oid(commit_oid)
        # update existing ontology
        version = o.versions.build({ :commit_oid => commit_oid, :user => user }, { without_protection: true })
        o.ontology_version = version
        o.save!
      end
    else
      # create new ontology
      clazz      = Ontology::FILE_EXTENSIONS_DISTRIBUTED.include?(File.extname(filepath)) ? DistributedOntology : SingleOntology
      o          = clazz.new
      o.basepath = basepath
      o.file_extension = File.extname(filepath)

      o.iri  = iri || "http://#{Settings.hostname}/#{path}/#{basepath}"
      o.name = filepath.split('/')[-1].split(".")[0].capitalize

      o.repository = self
      o.present = true
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

  def paths_starting_with(path, commit_oid=nil)
    dir = dir?(path, commit_oid) ? path : path.split('/')[0..-2].join('/')
    contents = git.folder_contents(commit_oid, dir)

    contents.map{ |entry| entry[:path] }.select{ |p| p.starts_with?(path) }
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
          file: file,
          ontologies: ontologies.find_with_path(path).parents_first
        }
      else
        entries = list_folder(path, commit_oid)
        entries.each do |name, es|
          es.each do |e|
            e[:ontologies] = ontologies.find_with_path(e[:path]).parents_first
          end
          es.sort_by! { |e| -e[:ontologies].size }
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

  def commit_message(oid=nil)
    git.commit_message(oid)
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
  #                     :offset (number of commits to skip)
  #                     :walk_order (Rugged-Walkorder)
  def commits(options={}, &block)
    git.commits(options, &block)
  end

  def suspended_save_ontologies(options={})
    commits(options) { |commit_oid|
      git.changed_files(commit_oid).each { |f|
        if f.add? || f.change?
          save_ontology(commit_oid, f.path, options.delete(:user))
        end
      }
    }
  end

  # saves all ontologies at the current state in the database
  def save_current_ontologies(user=nil)
    git.files do |entry|
      save_ontology entry.last_change[:oid], entry.path, user
    end
  end

end
