module Repository::Validations
  extend ActiveSupport::Concern

  VALID_NAME_REGEX = /^[A-Za-z0-9_\.\-\ ]{3,32}$/
  VALID_PATH_REGEX = /^[a-z0-9_\.\-]{3,32}$/

  included do
    before_validation :set_path

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
  end

  def set_path
    self.path ||= name.parameterize if name
  end
end

class UnreservedValidator < ActiveModel::Validator

  REVERSED_NAMES = Rails.application.routes.routes.map{ |r| r.path.spec.to_s }.compact.map{ |s| s.split('/')[1] }.compact.map{ |s| s.split('(',2)[0] }.map{ |s| s.split(':',2)[0] }.select(&:present?).uniq

  def validate(record)
    if is_reserved_name?(record.path)
      record.errors[:name] = "is a reserved name"
    end
  end

  # toplevel namespaces in routing are reserved words
  def is_reserved_name?(name)
    REVERSED_NAMES.include?(name)
  end
end

class NameNotChangedAfterSetValidator < ActiveModel::Validator

  def validate(record)
    if name_was_changed_to_different_name?(record)
      record.errors[:name] = "we do not allow renaming, right now"
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
