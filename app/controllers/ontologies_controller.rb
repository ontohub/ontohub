class OntologiesController < InheritedResources::Base
  has_scope :page, :default => 1

  before_filter :changeable?, :only => [:edit, :update]

  def new
    @version = build_resource.versions.build
  end

  def create
    @version = build_resource.versions.first
    @version.user = current_user
    super
  end

protected

  def changeable?
    resource.changeable?
  end
end
