class SerializationsController < InheritedResources::Base
  has_pagination
  #after_action :verify_authorized, :except => [:index, :show]

end
