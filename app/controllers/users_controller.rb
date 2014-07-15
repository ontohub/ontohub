#
# Displays a user profile
#
class UsersController < InheritedResources::Base

  actions :show
  respond_to :json, :xml

  def show
    @content_type = :users
    super do |format|
      format.html do
        @versions = resource.ontology_versions.latest.limit(10).all
        @failed_versions = resource.ontology_versions.failed
        @comments = resource.comments.latest.limit(10).all
      end
      format.json do
        render :json => resource.to_json(:only => [:name, :name])
      end
      format.xml do
        render :xml => resource.to_xml(:only => [:id, :name])
      end
    end
  end

end
