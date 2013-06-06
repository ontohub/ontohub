module Repository::Validations
  extend ActiveSupport::Concern

  VALID_NAME_REGEX = /^[A-Za-z0-9_\.\-\ ]{3,32}$/
  VALID_PATH_REGEX = /^[a-z0-9_\.\-]+$/
  
  included do
    before_validation :set_path

    validates :name, presence: true,
                     uniqueness: { case_sensitive: false }, format: VALID_NAME_REGEX
    
    validates :path, presence: true, uniqueness: { case_sensitive: true }, format: VALID_PATH_REGEX
  end

  def set_path
    self.path ||= name.parameterize if name
  end
end