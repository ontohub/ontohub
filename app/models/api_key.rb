class ApiKey < ActiveRecord::Base
  KEY_LENGTH = 48
  STATES = %w(valid invalid)

  belongs_to :user
  attr_accessible :key, :status

  before_validation :initialize_key

  validates :user, presence: true
  validates :key, presence: true, uniqueness: true
  validates :status, inclusion: {in: STATES}

  private
  def initialize_key
    generate_key! unless key
    set_status! unless status
    true
  end

  def generate_key!
    self.key = SecureRandom.hex(KEY_LENGTH)
  end

  def set_status!
    self.status = 'valid'
  end
end
