module Repository::Access
  extend ActiveSupport::Concern

  OPTIONS = %w[public_r public_rw private_r private_rw]
  DEFAULT_OPTION = OPTIONS[0]

  def is_private
    access.start_with?('private')
  end

  def private_r?
    access == 'private_r'
  end

  def private_rw?
    access == 'private_rw'
  end

  def public_rw?
    access == 'public_rw'
  end

  def public_r?
    access == 'public_r'
  end

  def self.as_read_only(access)
    access.split('_').first + '_r'
  end

  private

  def clear_readers
    if access_changed? && (access_was == 'private_r' || access_was == 'private_rw')
      permissions.where(role: 'reader').destroy_all
    end
  end

end
