class User < ActiveRecord::Base
  
  include User::Authentication
  
end
