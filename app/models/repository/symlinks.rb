#
# Generates a symlink for exposing the repositories via git daemon
#
module Repository::Symlinks
  extend ActiveSupport::Concern

  included do
    after_save     :symlink_update, if: :path_changed?
    before_destroy :symlink_remove
  end

  def symlink_name
    Ontohub::Application.config.git_daemon_path.join("#{path}.git")
  end

  protected

  def create_hooks_symlink
    hooks_symlink_name = local_path.join("hooks")
    hooks_symlink_name.rmtree
    hooks_symlink_name.make_symlink(Rails.root.join('git','hooks').
      # replace capistrano-style release with 'current'-symlink
      sub(%r{/releases/\d+/}, '/current/'))
  end

  def symlink_update
    Ontohub::Application.config.git_daemon_path.mkpath
    symlink_remove
    symlink_name.make_symlink local_path
  end

  def symlink_remove
    symlink_name.unlink if symlink_name.exist?
  end

end
