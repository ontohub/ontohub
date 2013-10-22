require 'ssh_keys'

module Key::Filesystem
  extend ActiveSupport::Concern

  included do
    after_create :add_key
    after_destroy :remove_key
  end

  def add_key
    SshKeys.new.refresh_key id, key
  end

  def remove_key
    SshKeys.new.remove_key id
  end

end