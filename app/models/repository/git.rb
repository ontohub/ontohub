require 'git_repository'

module Repository::Git
  extend ActiveSupport::Concern

  delegate :commit_id, :dir?, :empty?, :get_file, :has_changed?,
           :is_head?, :path_exists?, :paths_starting_with,
           :points_through_file?, :deepest_existing_dir,
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
    create_hooks_symlink
  end

  def destroy_git
    git.destroy
  end

  def delete_file(filepath, user, message = nil, &block)
    commit_oid = git.delete_file(user_info(user), filepath, &block)
    commit_for!(commit_oid).commit_oid
    OntologySaver.new(self).
      mark_ontology_as_having_file(filepath, has_file: false)
  end

  def save_file(tmp_file, filepath, message, user, do_not_parse: false)
    version = nil

    git.add_file(user_info(user), tmp_file, filepath, message) do |commit_oid|
      ontology_version_options = OntologyVersionOptions.new(
        filepath, user, do_not_parse: do_not_parse)
      version = OntologySaver.new(self).
        save_ontology(commit_oid, ontology_version_options)
    end
    touch
    version
  end

  def save_file_only(tmp_file, filepath, message, user)
    commit = nil
    git.add_file(user_info(user), tmp_file, filepath, message) do |commit_oid|
      commit = commit_oid
    end
    commit_for!(commit)
    touch
    commit
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

  def user_info(user)
    if user
      {email: user.email, name: user.name}
    else
      {email: Settings.git.fallbacks.committer_email,
       name: Settings.git.fallbacks.committer_name}
    end
  end

  def master_file?(ontology, ontology_version_options)
    ontology.path == ontology_version_options.pre_saving_filepath
  end
end
