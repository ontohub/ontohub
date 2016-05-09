#
# Generates a symlink for exposing the repositories via git daemon
#
module Repository::Symlinks
  extend ActiveSupport::Concern

  included do
    after_save     :symlinks_update, if: :symlink_update?
    before_destroy :symlinks_remove
  end

  SUPPORTED_LINK_CATEGORIES = %i(git_daemon git_ssh)

  def symlink_path(category)
    unless SUPPORTED_LINK_CATEGORIES.include?(category)
      raise "Unsupported symlink category: #{category.inspect}"
    end
    Ontohub::Application.config.send(:"#{category}_path").join("#{path}.git")
  end

  protected

  def symlink_update?
    access_changed? || path_changed?
  end

  def create_hooks_symlink
    hooks_symlink_name = local_path.join("hooks")
    hooks_symlink_name.rmtree
    hooks_symlink_name.
      make_symlink(cleanup_release(Rails.root.join('git','hooks')))
  end

  def symlinks_update
    if public_r? || public_rw?
      create_cloning_symlink(:git_daemon)
    else
      remove_cloning_symlink(:git_daemon)
    end
    create_cloning_symlink(:git_ssh)
  end

  def symlinks_remove
    SUPPORTED_LINK_CATEGORIES.each do |category|
      remove_cloning_symlink(category)
    end
  end

  def create_cloning_symlink(category)
    symlink_path(category).join('..').mkpath
    remove_cloning_symlink(category)
    symlink_path(category).make_symlink(cleanup_release(local_path))
  end

  def remove_cloning_symlink(category)
    symlink_path(category).unlink if symlink_path(category).exist?
  end

  # Replace capistrano-style release with 'current'-symlink.
  def cleanup_release(path)
    PathsInitializer.cleanup_release(path)
  end
end
