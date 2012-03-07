class User < ActiveRecord::Base
  
  include User::Authentication
  
  attr_accessible :email, :name, :admin, :password, :as => :admin
  
  def to_s
    name? ? name : email.split("@").first
  end
  
  def delete
    self.email = nil
    self.password = nil
    self.deleted_at = Time.now
    save(:validate => false)
  end
  
end
