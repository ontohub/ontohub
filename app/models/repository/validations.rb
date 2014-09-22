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

  def validate(record)
    if is_reserved_name?(record.path)
      record.errors[:name] = "is a reserved name"
    end
  end

  protected

  # toplevel namespaces in routing are reserved words
  def is_reserved_name?(name)
    toplevel_namespaces.include?(name)
  end

  def toplevel_namespaces
    Rails.application.routes.routes.
      map { |r| toplevel_route(r.path.spec.to_s) }.uniq.compact
  end

  def toplevel_route(route)
    non_present_to_nil(remove_colon(remove_parens(first_hierarchy_part(route))))
  end

  def first_hierarchy_part(route)
    route.split('/', 3)[1] || ''
  end

  def remove_parens(route_part)
    route_part.split('(', 2).first || ''
  end

  def remove_colon(route_part)
    route_part.split(':', 2).first || ''
  end

  def non_present_to_nil(route_part)
    route_part.present? ? route_part : nil
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
