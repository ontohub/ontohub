module Repository::Importing
  extend ActiveSupport::Concern

  SOURCE_TYPES = %w( git svn )
  STATES = %w( pending processing done failed )

  included do
    include StateUpdater

    validates_inclusion_of :state,       in: STATES
    validates_inclusion_of :source_type, in: SOURCE_TYPES, if: :remote?

    after_create :async_remote_clone, if: :remote?

    async_method :remote_clone, :remote_pull
  end

  def remote?
    source_address?
  end

  # do not allow new actions if running
  def locked?
    %w( pending processing ).include?(state)
  end

  # enqueues a clone job
  def remote_clone
    remote_send :clone, source_address
  end

  # enqueues a pull job
  def remote_pull
    remote_send :fetch_and_reset
  end

=begin
  # enqueues a remote job
  def async_remote(method)
    raise "object is #{state}" if locked?
    update_state! 'pending'
    async :remote_send, method
  end
=end

  def remote_send(method, *args)
    user    = permissions.where(subject_type: User, role: 'owner').first!.subject
    method  = method.to_s
    method += '_svn' if source_type=='svn'

    update_state! 'processing'
    do_or_set_failed do
      result = git.send(method, *args)
      
      save_current_ontologies(user)
      update_state! 'done'

      result
    end
  end

  module ClassMethods
    # creates a new repository and imports the contents from the remote repository
    def import_remote(type, user, source, name, params={})
      raise ArgumentError, "invalid source type: #{type}" unless SOURCE_TYPES.include?(type)
      raise Repository::ImportError, "#{source} is not a #{type} repository" unless GitRepository.send "is_#{type}_repository?", source

      params[:name]           = name
      params[:source_type]    = type
      params[:source_address] = source

      r = Repository.new(params)
      r.user = user
      r.save!
      r
    end
  end
  
end