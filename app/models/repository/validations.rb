module Repository::Validations
  extend ActiveSupport::Concern

  VALID_NAME_REGEX = /^[A-Za-z0-9_\.\-\ ]{3,32}$/
  VALID_PATH_REGEX = /^[a-z0-9_\.\-]{3,32}$/
  
  included do
    before_validation :set_path

    validates :name, presence: true,
                     uniqueness: { case_sensitive: false },
                     format: VALID_NAME_REGEX
    
    validates :path, presence: true,
                     uniqueness: { case_sensitive: true },
                     format: VALID_PATH_REGEX
    
    validates_with UnreservedValidator
  end

  def set_path
    self.path ||= name.parameterize if name
  end
end

class UnreservedValidator < ActiveModel::Validator
  def validate(record)
    if is_reserved_name?(record.path)
      record.errors[:path] = "is a reserved path"
    end
  end

  # toplevel namespaces in routing are reserved words
  def is_reserved_name?(name)
    Rails.application.routes.routes.map{ |r| r.path.spec.to_s }.select{ |s| !s.nil? }.map{ |s| s.split('/')[1] }.select{ |s| !s.nil? }.map{ |s| s.split('(')[0] }.map{ |s| s.split(':')[0] }.select{ |s| !s.empty? }.uniq.include?(name)
  end
end
