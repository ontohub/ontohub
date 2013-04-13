# 
# Displays versions of a ontology
# 
class OntologyVersionsController < InheritedResources::Base
  defaults :collection_name => :versions, :finder => :find_by_number!
  actions :index, :show, :new, :create
  belongs_to :ontology
  respond_to :json, :xml

  before_filter :check_changeable, only: [:new, :create]

  # TODO Needs testing !!!
  def show
    file = resource.raw_file
    
    send_file file.current_path, filename: file.identifier
  rescue Errno::ENOENT, NoMethodError => e
    redirect_to collection_path, flash: { error: "The file was not found: #{e.message}" }
  end

  def new
    build_resource.source_url = collection.latest.first.source_url
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
    redirect_to :back
  end
  
protected

  def check_changeable
    unless parent.changeable?
      redirect_to collection_path, flash: { error: 'There are pending ontology versions.' }
    end
  end
end
