# 
# Displays versions of a ontology
# 
class OntologyVersionsController < InheritedResources::Base
  defaults :collection_name => :versions
  actions :index, :show, :new, :create
  belongs_to :ontology
  respond_to :json, :xml

  before_filter :check_changeable, only: [:new, :create]

  def show
    o = resource.ontology

    path = resource.raw_file.current_path

    mime = o.logic.mimetype
    mime = 'text/plain' if mime.empty?

    name = o.name.to_slug.normalize.to_s
    name = File.basename(path) if name.empty?

    ext = o.logic.extension
    name += ".#{ext}" unless ext.empty?

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
