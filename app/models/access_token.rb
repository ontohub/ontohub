class AccessToken < ActiveRecord::Base
  LENGTH = 20

  belongs_to :repository
  attr_accessible :expiration, :token

  def to_s
    token
  end

  def expired?
    Time.now > expiration
  end

  def refresh!
    self.expiration = self.class.fresh_expiration_date
    save!
  end

  def replace
    self.destroy
    self.class.build_for(repository)
  end

  def self.build_for(repository)
    AccessToken.new({repository: repository,
      expiration: fresh_expiration_date,
      token: SecureRandom.hex(LENGTH)}, {without_protection: true})
  end

  protected

  def self.fresh_expiration_date
    Settings.access_token.expiration_minutes.minutes.from_now
  end
end
