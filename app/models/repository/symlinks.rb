#
# Generates a symlink for exposing the repositories via git daemon
#
module Repository::Symlinks
  extend ActiveSupport::Concern

  included do
    after_save     :symlinks_update, if: :path_changed?
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

  def create_hooks_symlink
    hooks_symlink_name = local_path.join("hooks")
    hooks_symlink_name.rmtree
    hooks_symlink_name.make_symlink(Rails.root.join('git','hooks').
      # replace capistrano-style release with 'current'-symlink
      sub(%r{/releases/\d+/}, '/current/'))
  end

  def symlinks_update
    create_cloning_symlink(:git_daemon) if public_r? || public_rw?
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
    symlink_path(category).make_symlink(local_path)
  end

  def remove_cloning_symlink(category)
    symlink_path(category).unlink if symlink_path(category).exist?
  end
end
