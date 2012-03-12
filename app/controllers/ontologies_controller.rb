class OntologiesController < InheritedResources::Base

  has_scope :page, :default => 1

  load_and_authorize_resource :except => [:index, :show]

  respond_to :json

  def new
    @version = build_resource.versions.build
  end

  def create
    @version = build_resource.versions.first
    @version.user = current_user
    super
    @version.async :parse
  end

end
