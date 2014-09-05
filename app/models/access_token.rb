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

  def self.create_for(repository)
    a = insecure_build_for(repository) until !a.nil? && a.valid?
    a.save!
    a
  end

  protected

  def self.fresh_expiration_date
    Settings.access_token.expiration_minutes.minutes.from_now
  end

  def self.insecure_build_for(repository)
    AccessToken.new({repository: repository,
      expiration: fresh_expiration_date,
      token: SecureRandom.hex(LENGTH)}, {without_protection: true})
  end
end
