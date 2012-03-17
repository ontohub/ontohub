# 
# Displays versions of a ontology
# 
class OntologyVersionsController < InheritedResources::Base
  defaults :collection_name => :versions
  actions :index, :show, :new, :create
  belongs_to :ontology
  respond_to :json, :xml

  before_filter :check_changeable, only: [:new, :create]

  # TODO Needs testing !!!
  def show
    o = resource.ontology
    
    path = resource.raw_file.current_path
    
    name = o.to_s.parameterize
    name = File.basename(path) if name.blank?

    if o.logic
      mime = o.logic.mimetype if o.logic
      
      ext = o.logic.extension
      name << ".#{ext}" unless ext.blank?
    end
    
    mime ||= 'text/plain' if mime.blank?

    send_file path, type: mime, filename: name
  rescue Errno::ENOENT, NoMethodError
    redirect_to collection_path, flash: { error: 'The cake is a lie.' }
  end

  def new
    build_resource.source_uri = collection.latest.first.source_uri
  end

  def create
    build_resource.user = current_user

    super do |success, failure|
      success.html { redirect_to collection_path }
    end
  end

protected

  def check_changeable
    unless parent.changeable?
      redirect_to collection_path, flash: { error: 'There are pending ontology versions.' }
    end
  end
end
