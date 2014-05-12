#
# Displays versions of an ontology
#
class OntologyVersionsController < InheritedResources::Base

  defaults :collection_name => :versions, :finder => :find_by_number!
  actions :index, :show, :new, :create
  belongs_to :ontology
  respond_to :json, :xml

  before_filter :check_changeable, only: [:new, :create]
  before_filter :check_read_permissions

  # TODO Needs testing !!!
  def show
    resource.checkout_raw!

    send_file resource.raw_path, filename: File.basename(resource.ontology.path)
  rescue Errno::ENOENT, NoMethodError => e
    redirect_to collection_path, flash: { error: "The file was not found: #{e.message}" }
  end

  def create
    build_resource.user = current_user

    super do |success, failure|
      success.html { redirect_to collection_path }
    end
  end

  def oops
    resource.build_request.save!
    flash[:notice] = "Your request is send to OOPS!"
    redirect_to ontology_entities_path(resource.ontology)
  end


  protected

  def collection
    if parent.parent
      @versions = parent.parent.versions
    else
      super
    end
  end

  def check_changeable
    unless parent.changeable?
      redirect_to collection_path, flash: { error: 'There are pending ontology versions.' }
    end
  end

  def check_read_permissions
    authorize! :show, parent.repository
  end
end
