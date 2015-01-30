require 'git_repository'

module Repository::GitRepositories
  extend ActiveSupport::Concern

  delegate :commit_id, :dir?, :empty?, :get_file, :has_changed?,
    :is_head?, :path_exists?, :paths_starting_with, :points_through_file?,
    to: :git

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

  def walk_commits(*args, &block)
    git.commits(*args, &block)
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

  def delete_file(filepath, user, message = nil, &block)
    commit_oid = git.delete_file(user_info(user), filepath, &block)
    commit_for!(commit_oid).commit_oid
  end

  def save_file(tmp_file, filepath, message, user, do_not_parse: false)
    version = nil

    git.add_file(user_info(user), tmp_file, filepath, message) do |commit_oid|
      ontology_version_options = OntologyVersionOptions.new(
        filepath, user, do_not_parse: do_not_parse)
      version = save_ontology(commit_oid, ontology_version_options)
    end
    touch
    version
  end

  def save_file_only(tmp_file, filepath, message, user)
    commit = nil
    name = user ? user.name : Settings.fallback_commit_user
    email = user ? user.email : Settings.fallback_commit_email
    userdata = {email: email, name: name}
    git.add_file(userdata, tmp_file, filepath, message) do |commit_oid|
      commit = commit_oid
    end
    commit_for!(commit)
    touch
    commit
  end

  def save_ontology(commit_oid, ontology_version_options)
    # we expect that this method is only called, when the ontology is 'present'
    return unless Ontology.file_extensions.include?(
      File.extname(ontology_version_options.filepath))

    ontology = find_or_create_ontology(ontology_version_options)

    return unless master_file?(ontology, ontology_version_options)
    return if ontology.versions.find_by_commit_oid(commit_oid)

    version = create_version(ontology, commit_oid, ontology_version_options)
    ontology.present = true
    ontology.save!

    version
  end

  def find_or_create_ontology(ontology_version_options)
    ontology = find_existing_ontology(ontology_version_options)

    if !ontology
      iri = generate_iri(File.basepath(ontology_version_options.filepath))
      ontology = create_ontology(ontology_version_options.filepath, iri)
    end

    ontology
  end

  def find_existing_ontology(ontology_version_options)
    ontologies.with_basepath(
      File.basepath(ontology_version_options.pre_saving_filepath)).
      without_parent.first
  end

  def create_ontology(filepath, iri)
    clazz = Ontology.file_extensions_distributed.include?(
      File.extname(filepath)) ? DistributedOntology : SingleOntology
    ontology = clazz.new

    ontology.basepath = File.basepath(filepath)
    ontology.file_extension = File.extname(filepath)
    ontology.iri = iri
    ontology.name = filepath.split('/')[-1].split(".")[0].capitalize
    ontology.repository = self
    ontology.present = true
    ontology.save!

    ontology
  end

  def create_version(ontology, commit_oid, ontology_version_options)
    version = ontology.versions.build(
      { commit_oid: commit_oid,
        user: ontology_version_options.user,
        commit: commit_for!(commit_oid),
        # We can't use the ontology's filepath bacause it might have changed
        basepath: File.basepath(ontology_version_options.filepath),
        file_extension: File.extname(ontology_version_options.filepath),
        fast_parse: ontology_version_options.fast_parse },
      { without_protection: true })
    version.do_not_parse! if ontology_version_options.do_not_parse
    version.save!
    ontology.ontology_version = version
    ontology.save!

    version
  end

  def commit_for!(commit_oid)
    instance = Commit.where(repository_id: self, commit_oid: commit_oid).
      first_or_initialize
    instance.fill_commit_instance! unless instance.persisted?
    instance
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
    walk_commits(limit: 3)
  end

  def suspended_save_ontologies(options={})
    versions = []
    commits_count = 0
    highest_change_file_count = 0
    walk_commits(options) { |commit|
      commits_count += 1
      current_file_count = 0
      git.changed_files(commit.oid).each { |f|
        current_file_count += 1
        if f.added? || f.modified?
          ontology_version_options = OntologyVersionOptions.new(
            f.path,
            options.delete(:user),
            fast_parse: has_changed?(f.path, commit.oid),
            do_not_parse: true)
          versions << save_ontology(commit.oid, ontology_version_options)
        elsif f.renamed?
          ontology_version_options = OntologyVersionOptions.new(
            f.path,
            options.delete(:user),
            fast_parse: has_changed?(f.path, commit.oid),
            do_not_parse: true,
            previous_filepath: f.delta.old_file[:path])
          versions << save_ontology(commit.oid, ontology_version_options)
        # TODO: elsif f.deleted?
        end
      }
      highest_change_file_count = [highest_change_file_count,
                                   current_file_count].max
    }

    priority = applicable_for_priority?(commits_count,
                                        highest_change_file_count)
    schedule_batch_parsing(versions, priority_mode: priority)
  end

  def schedule_batch_parsing(versions, priority_mode: false)
    grouped_versions = versions.compact.group_by(&:path)
    grouped_versions.each do |k,versions|
      optioned_versions = versions.map do |version|
        [version.id, { fast_parse: version.fast_parse }]
      end
      OntologyBatchParseWorker.
        perform_async_with_priority(priority_mode, optioned_versions)
    end
  end

  def applicable_for_priority?(commits_count, highest_change_file_count)
    (commits_count <= priority_settings.commits) &&
      (highest_change_file_count <= priority_settings.changed_files_per_commit)
  end

  def priority_settings
    @priority_settings ||= OpenStruct.new(Settings.git[:push_priority])
  end

  def user_info(user)
    {email: user.email, name: user.name}
  end

  def master_file?(ontology, ontology_version_options)
    ontology.path == ontology_version_options.pre_saving_filepath
  end

  def generate_iri(basepath)
    "http://#{Settings.hostname}/#{self.path}/#{basepath}"
  end
end
