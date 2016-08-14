module Repository::Validations
  extend ActiveSupport::Concern

  VALID_NAME_REGEX = /^[A-Za-z0-9_\.\-\ ]{3,32}$/
  VALID_PATH_REGEX = /^[a-z0-9_\.\-]{3,32}$/

  included do
    validates :name, presence: true,
                     uniqueness: { case_sensitive: false },
                     format: VALID_NAME_REGEX,
                     if: :name_changed?

    validates_with NameNotChangedAfterSetValidator, if: :name_changed?

    validates :path, presence: true,
                     uniqueness: { case_sensitive: true },
                     format: VALID_PATH_REGEX,
                     if: :path_changed?

    validates_with UnreservedValidator, if: :path_changed?

    validates :state, inclusion: {in: Repository::Importing::STATES}
    validates_with SourceTypeValidator, if: :source_address?
    validates :remote_type, presence: true, if: :source_address?
    validates_with RemoteTypeValidator

    validates :access,
      presence: true,
      inclusion: {in: Repository::Access::OPTIONS},
      unless: :mirror?
    validates :access,
      presence: true,
      inclusion: {in: Repository::Access::OPTIONS_MIRROR},
      if: :mirror?
  end

  class UnreservedValidator < ActiveModel::Validator
    def validate(record)
      record.errors[:name] = 'is a reserved name' if reserved_name?(record.path)
    end

    protected

    # toplevel namespaces in routing are reserved words
    def reserved_name?(name)
      RESERVED_NAMES.include?(name)
    end

    def self.toplevel_namespaces
      Rails.application.routes.routes.
        map { |r| toplevel_route(r.path.spec.to_s) }.uniq.compact
    end

    def self.toplevel_route(route)
      non_present_to_nil(remove_colon(remove_parens(first_hierarchy_part(
        route))))
    end

    def self.first_hierarchy_part(route)
      route.split('/', 3)[1] || ''
    end

    def self.remove_parens(route_part)
      route_part.split('(', 2).first || ''
    end

    def self.remove_colon(route_part)
      route_part.split(':', 2).first || ''
    end

    def self.non_present_to_nil(route_part)
      route_part.present? ? route_part : nil
    end

    # It is against our code style conventions to place a constant here,
    # but it is necessary to have all the inherent methods defined above of it.
    RESERVED_NAMES = toplevel_namespaces + ['new']
  end

  class NameNotChangedAfterSetValidator < ActiveModel::Validator
    def validate(record)
      if name_was_changed_to_different_name?(record)
        record.errors[:name] = 'we do not allow renaming, right now'
      end
    end

    def name_was_changed_to_different_name?(record)
      !(was_name_nil?(record) && name_is_present_now?(record))
    end

    def was_name_nil?(record)
      record.name_was.nil?
    end

    def name_is_present_now?(record)
      record.name.present?
    end
  end


  class RemoteTypeValidator < ActiveModel::Validator
    def validate(record)
      if Repository::Importing::REMOTE_TYPES.include?(record.remote_type) &&
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
      if record.remote? && !record.source_type.present?
        record.errors[:source_address] = 'not a valid remote repository '\
          'or not accessible '\
          "(types supported: #{Repository::SOURCE_TYPES.join(', ')})"
        record.errors[:source_type] = 'not present'
      end
    end
  end
end
