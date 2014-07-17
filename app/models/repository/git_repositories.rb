require 'git_repository'

module Repository::GitRepositories
  extend ActiveSupport::Concern

  delegate :get_file, :dir?, :path_exists?, :points_through_file?, :has_changed?, :commits, to: :git

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

  def delete_file(filepath, user, message = nil, &block)
    message ||= "delete file #{filepath}"
    git.delete_file(user_info(user), filepath, &block)
  end

  def save_file(tmp_file, filepath, message, user, iri=nil)
    version = nil

    git.add_file(user_info(user), tmp_file, filepath, message) do |commit_oid|
      version = save_ontology(commit_oid, filepath, user, iri: iri)
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

  def save_ontology(commit_oid, filepath, user=nil, iri: nil, fast_parse: false, do_not_parse: false, previous_filepath: nil)
    # we expect that this method is only called, when the ontology is 'present'
    return unless Ontology.file_extensions.include?(File.extname(filepath))
    version = nil
    basepath = File.basepath(filepath)
    file_extension = File.extname(filepath)
    o = ontologies.with_basepath(
      (previous_filepath ? File.basepath(previous_filepath) : basepath)).
      without_parent.first


    if o
      return if !master_file?(o, previous_filepath || filepath)
      o.present = true
      unless o.versions.find_by_commit_oid(commit_oid)
        # update existing ontology
        version = o.versions.build({ commit_oid: commit_oid,
                                     user: user,
                                     basepath: basepath,
                                     file_extension: file_extension,
                                     fast_parse: fast_parse },
                                   { without_protection: true })
        o.ontology_version = version
        version.do_not_parse! if do_not_parse
        o.save!
      end
    else
      # create new ontology
      clazz      = Ontology.file_extensions_distributed.include?(File.extname(filepath)) ? DistributedOntology : SingleOntology
      o          = clazz.new
      o.basepath = basepath
      o.file_extension = file_extension

      o.iri  = iri || generate_iri(basepath)
      o.name = filepath.split('/')[-1].split(".")[0].capitalize

      o.repository = self
      o.present = true
      o.save!
      version = o.versions.build({ commit_oid: commit_oid,
                                   user: user,
                                   basepath: basepath,
                                   file_extension: file_extension,
                                   fast_parse: fast_parse },
                                 { without_protection: true })
      version.do_not_parse! if do_not_parse
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

    contents.map{ |git_file| git_file.path }.select{ |p| p.starts_with?(path) }
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

  def suspended_save_ontologies(options={})
    versions = []
    commits(options) { |commit|
      git.changed_files(commit.oid).each { |f|
        if f.added? || f.modified?
          versions << save_ontology(commit.oid, f.path, options.delete(:user),
            fast_parse: has_changed?(f.path, commit.oid),
            do_not_parse: true)
        elsif f.renamed?
          versions << save_ontology(commit.oid, f.path, options.delete(:user),
            fast_parse: has_changed?(f.path, commit.oid),
            do_not_parse: true,
            previous_filepath: f.delta.old_file[:path])
        end
      }
    }

    schedule_batch_parsing(versions)
  end

  def schedule_batch_parsing(versions)
    grouped_versions = versions.compact.group_by(&:path)
    grouped_versions.each do |k,versions|
      optioned_versions = versions.map do |version|
        [version.id, { fast_parse: version.fast_parse }]
      end
      OntologyBatchParseWorker.perform_async(optioned_versions)
    end
  end

  def user_info(user)
    {email: user.email, name: user.name}
  end

  def master_file?(ontology, filepath)
    ontology.path == filepath
  end

  def generate_iri(basepath)
    "http://#{Settings.hostname}/#{self.path}/#{basepath}"
  end
end
