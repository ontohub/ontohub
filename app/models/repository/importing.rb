module Repository::Importing
  extend ActiveSupport::Concern

  SOURCE_TYPES = %w( git svn )
  STATES = %w( pending processing done failed )

  included do
    include StateUpdater

    validates_inclusion_of :state,       in: STATES
    validates_inclusion_of :source_type, in: SOURCE_TYPES, if: :remote?

    after_create :async_clone, if: :remote?
  end

  def remote?
    source_address?
  end

  # do not allow new actions if running
  def locked?
    %w( pending processing ).include?(state)
  end

  # enqueues a clone job
  def async_clone
    async_remote :clone
  end

  # enqueues a synchronize job
  def async_synchronize
    async_remote :synchronize
  end

  # enqueues a remote job
  def async_remote(method)
    raise "object is #{state}" if locked?
    update_state! 'pending'
    async :remote_send, method
  end

  def remote_send(method)
    update_state! 'processing'
    do_or_set_failed do
      remote_repository.send method
      update_state! 'done'
    end
  end

  def remote_repository
    RemoteRepository.instance(self, user)
  end

  module ClassMethods
    # creates a new repository and imports the contents from the remote repository
    def import_remote(type, user, source, name, params={})
      raise ArgumentError, "invalid source type: #{type}" unless SOURCE_TYPES.include?(type)
      raise Repository::ImportError, "#{source} is not a #{type} repository" unless GitRepository.send "is_#{type}_repository?", source

      params[:name]           = name
      params[:source_type]    = type
      params[:source_address] = source

      r = Repository.create!(params)
      r.user = user
      r.save!
      r

    end
  end
  
end