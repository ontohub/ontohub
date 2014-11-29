#
# States:
# * pending    - Job is enqueued.
# * fetching   - Fetching new commits from the remote repository.
# * processing - Inserting fetched commits into the local database-
# * done       - Everthing is fine, nothing to do-
# * failed     - Something has gone wrong.
#
module Repository::Importing
  extend ActiveSupport::Concern

  SOURCE_TYPES = %w( git svn )
  REMOTE_TYPES = %w( fork mirror )
  STATES = State::STATES

  IMPORT_INTERVAL = 15.minutes

  included do
    include StateUpdater

    scope :with_source, where("source_type IS NOT null")

    # Ready for pulling
    scope :outdated, ->{
      with_source
      .where("imported_at IS NULL or imported_at < ?", IMPORT_INTERVAL.ago )
      .where(state: 'done')
    }

    validates_inclusion_of :state,       in: STATES
    validates_with SourceTypeValidator, if: :source_address?
    validates_presence_of :remote_type, if: :source_address?
    validates_with RemoteTypeValidator

    before_validation :clean_and_initialize_record
    after_create ->() { async_remote :clone }, if: :source_address?
  end

  def mirror?
    remote_type == 'mirror'
  end

  def fork?
    remote_type == 'fork'
  end

  def convert_to_local!
    self.remote_type = 'fork'
    save!
  end

  # do not allow new actions in specific states
  def locked?
    !%w( done failed ).include?(state)
  end

  # enqueues a pull/clone job
  def async_remote(method)
    raise "object is #{state}" if locked?
    update_state! 'pending'
    async :remote_send, method, remote_type
  end

  # executes a pull/clone job
  def remote_send(method, remote_type = nil)
    # build arguments
    args    = []
    args   << source_address if method == 'clone'

    # build method name
    method  = method.to_s
    method += '_svn' if source_type == 'svn'

    do_or_set_failed do
      process_fetch(method, args, remote_type)
    end
  end

  def process_fetch(method, args, remote_type)
    update_state! 'fetching'
    result = git.send(method, *args)
    convert_to_local! if remote_type == 'fork'

    update_state! 'processing'
    update_database_after_fetch(result)

    self.imported_at = Time.now
    update_state! 'done'

    result
  end

  def update_database_after_fetch(range)
    suspended_save_ontologies \
      start_oid:  range.current,
      stop_oid:   range.previous,
      walk_order: :reverse
  end

  module ClassMethods
    # Creates a new repository and imports the contents from the remote
    # repository.
    def import_remote(type, user, source, name, params={})
      unless SOURCE_TYPES.include?(type)
        raise ArgumentError, "invalid source type: #{type}"
      end
      unless GitRepository.send "is_#{type}_repository?", source
        raise Repository::ImportError, "#{source} is not a #{type} repository"
      end

      params[:name]           = name
      params[:source_type]    = type
      params[:source_address] = source
      params[:access]         = params[:access] ?
        Repository::Access.as_read_only(params[:access]) :
        Repository::Access::DEFAULT_OPTION

      r = Repository.new(params)
      r.user = user
      r.save!
      r
    end
  end

  protected

  class RemoteTypeValidator < ActiveModel::Validator
    def validate(record)
      if REMOTE_TYPES.include?(record.remote_type) &&
        !record.source_address.present?
        record.errors[:remote_type] =
          "Source address not set for #{record.remote_type}"
      elsif record.remote_type == 'mirror' && !record.source_type?
        record.errors[:remote_type] =
          "Source type not set for #{record.remote_type}"
      end
    end
  end

  class SourceTypeValidator < ActiveModel::Validator
    def validate(record)
      if record.mirror? && !record.source_type.present?
        record.errors[:source_address] = 'not a valid remote repository '\
          "(types supported: #{SOURCE_TYPES.join(', ')})"
        record.errors[:source_type] = "not present"
      end
    end
  end

  def clean_and_initialize_record
    self.remote_type = nil unless source_address?
    detect_source_type if new_record?
  end

  def detect_source_type
    if GitRepository.is_git_repository?(source_address)
      self.source_type = 'git'
    elsif GitRepository.is_svn_repository?(source_address)
      self.source_type = 'svn'
    end
  end
end
