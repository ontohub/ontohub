class SerializationsController < InheritedResources::Base
  has_pagination
  load_and_authorize_resource :except => [:index, :show]

end
