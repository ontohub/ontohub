#
# Generates a symlink for exposing the repositories via git daemon
#
module Repository::Symlink
  extend ActiveSupport::Concern

  included do
    after_save     :symlink_update, if: :path_changed?
    before_destroy :symlink_remove
  end

  def symlink_name
    Ontohub::Application.config.symlink_path.join("#{path}.git")
  end

  protected

  def symlink_update
    Ontohub::Application.config.symlink_path.mkpath
    symlink_remove
    symlink_name.make_symlink local_path
  end

  def symlink_remove
    symlink_name.unlink if symlink_name.exist?
  end

end
