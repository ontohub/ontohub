class User < ActiveRecord::Base
  
  include Common::Scopes
  include User::Authentication
  
  has_many :comments
  has_many :ontology_versions
  has_many :team_users
  has_many :teams, :through => :team_users
  has_many :metadata
  has_many :permissions, :as => :subject
  
  attr_accessible :email, :name, :admin, :password, :as => :admin
  
  strip_attributes :only => [:name, :email]
  
  scope :admin, where(:admin => true)
  
  scope :email_search, ->(query) { where "email #{connection.ilike_operator} ?", "%" << query << "%" }
  
  scope :autocomplete_search, ->(query) {
    where("name #{connection.ilike_operator} ? OR email #{connection.ilike_operator} ?", "%" << query << "%", query)
  }
  
  before_destroy :check_remaining_admins

  validates_length_of :name, :in => 3..32

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
    self.admin             = false
    
    save(:validate => false)
  end
  
  def email_required?
    deleted_at.nil?
  end
  
  def confirm!
    super

    if User.count < 2
      self.admin = true
      self.save
    end
  end
  
  protected
  
  def check_remaining_admins
    if User.admin.count < 2
      raise Permission::PowerVaccuumError, "What the hell ... nobody cares for your site if you remove the only one admin!"
    end
  end

end
