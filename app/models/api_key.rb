class ApiKey < ActiveRecord::Base
  KEY_LENGTH = 48
  STATES = %w(valid invalid)

  belongs_to :user
  attr_accessible :key, :state
  attr_accessible :user

  before_validation :initialize_key

  validates :user, presence: true
  validates :key, presence: true, uniqueness: true
  validates :state, inclusion: {in: STATES}

  scope :valid, -> { where(state: 'valid') }

  def self.create_new_key!(user)
    transaction do
      valid.where(user_id: user).
        find_each { |key| key.invalidate! }
      create!(user: user)
    end
  end

  def invalidate!
    self.state = 'invalid'
    save!
  end

  private
  def initialize_key
    generate_key! unless key
    set_valid! unless state
    true
  end

  def generate_key!
    self.key = SecureRandom.hex(KEY_LENGTH)
  end

  def set_valid!
    self.state = 'valid'
  end
end
