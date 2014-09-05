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
  STATES = %w( pending fetching processing done failed )

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
    validates_with SourceTypeValidator, if: :mirror?

    before_validation ->{ detect_source_type }
    after_create ->{ async_remote :clone }, if: :mirror?
  end

  def mirror?
    source_address?
  end

  def convert_to_local!
    source_address = nil
    source_type = nil
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
    async :remote_send, method
  end

  # executes a pull/clone job
  def remote_send(method)
    # build arguments
    args    = []
    args   << source_address if method == 'clone'

    # build method name
    method  = method.to_s
    method += '_svn' if source_type == 'svn'

    do_or_set_failed do
      update_state! 'fetching'
      result = git.send(method, *args)

      update_state! 'processing'
      suspended_save_ontologies \
        start_oid:  result.current,
        stop_oid:   result.previous,
        walk_order: Rugged::SORT_REVERSE

      self.imported_at = Time.now
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

  def detect_source_type
    if GitRepository.is_git_repository?(source_address)
      self.source_type = 'git'
    elsif GitRepository.is_svn_repository?(source_address)
      self.source_type = 'svn'
    end
  end

  class SourceTypeValidator < ActiveModel::Validator
    def validate(record)
      if record.mirror? && !record.source_type.present?
        record.errors[:source_address] = "not a valid remote repository (types supported: #{SOURCE_TYPES.join(', ')})"
        record.errors[:source_type] = "not present"
      end
    end
  end
end
