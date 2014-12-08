class AccessToken < ActiveRecord::Base
  belongs_to :repository
  attr_accessible :expiration, :token

  scope :expired, ->() { where('expiration <= ?', Time.now) }
  scope :unexpired, ->() { where('expiration > ?', Time.now) }

  def self.destroy_expired
    expired.find_each(&:destroy)
  end

  def self.create_for(ontology_version)
    # Although unlikely, the token could clash with another one. Generate tokens
    # until there is no conflict. This should converge extremely fast.
    access_token = nil
    while access_token.nil? || access_token.invalid? do
      access_token = build_for(ontology_version)
    end
    access_token.save!
    access_token
  end

  def self.fresh_expiration_date
    Settings.access_token.expiration_minutes.minutes.from_now
  end

  def self.build_for(ontology_version)
    repository = ontology_version.repository
    AccessToken.new(
      {repository: repository,
       expiration: fresh_expiration_date,
       token: generate_token_string(ontology_version, repository)},
      {without_protection: true})
  end

  def self.generate_token_string(ontology_version, repository)
    id = [
      repository.to_param, ontology_version.path,
      Time.now.strftime('%Y-%m-%d-%H-%M-%S-%6N')
    ].join('|')
    Digest::SHA2.hexdigest(id)
  end

  def to_s
    token
  end

  def expired?
    expiration <= Time.now
  end
end
