class User < ActiveRecord::Base
  
  include Common::Scopes
  include User::Authentication
  
  has_many :team_users
  has_many :teams, :through => :team_users
  
  attr_accessible :email, :name, :admin, :password, :as => :admin
  
  strip_attributes :only => [:name, :email]
  
  scope :email_search, ->(query) { where "email ILIKE ?", "%" << query << "%" }
  
  scope :autocomplete_search, ->(query) {
    limit(10).where("name ILIKE ? OR email ILIKE ?", "%" << query << "%", query)
  }
  
  def to_s
    name? ? name : email.split("@").first
  end
  
  # marks the user as deleted
  def delete
    self.encrypted_password = nil
    self.deleted_at = Time.now
    
    # nullify email fields
    @bypass_postpone       = true
    self.email             = nil
    self.unconfirmed_email = nil
    
    save(:validate => false)
  end
  
  def email_required?
    deleted_at.nil?
  end

end
