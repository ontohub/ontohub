class OntologiesController < InheritedResources::Base

  has_scope :page, :default => 1

  load_and_authorize_resource :except => [:index, :show]

  def new
    @version = build_resource.versions.build
  end

  def create
    @version = build_resource.versions.first
    @version.user = current_user
    super
  end

end
