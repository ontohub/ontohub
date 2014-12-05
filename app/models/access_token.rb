class AccessToken < ActiveRecord::Base
  belongs_to :repository
  attr_accessible :expiration, :token

  scope :unexpired, ->() { where('expiration > ?', Time.now) }

  def to_s
    token
  end

  def expired?
    expiration <= Time.now
  end

  def self.create_for(ontology_version)
    repository = ontology_version.repository
    a = insecure_build_for(ontology_version) until !a.nil? && a.valid?
    a.save!
    a
  end

  protected

  def self.fresh_expiration_date
    Settings.access_token.expiration_minutes.minutes.from_now
  end

  def self.insecure_build_for(ontology_version)
    repository = ontology_version.repository
    id = [repository.to_param, ontology_version.path,
      Time.now.strftime("%Y-%m-%d-%H-%M-%S-%6N")].join("|")
    AccessToken.new({repository: repository,
      expiration: fresh_expiration_date,
      token: Digest::SHA2.hexdigest(id)}, {without_protection: true})
  end
end
