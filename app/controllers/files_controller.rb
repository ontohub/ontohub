class FilesController < InheritedResources::Base
  defaults resource_class: RepositoryFile
  defaults singleton: true

  helper_method :repository, :ref, :oid, :path, :branch_name
  before_filter :check_write_permissions, only: [:new, :create, :update]
  before_filter :check_read_permissions

  def show
    if owl_api_header_in_accept_header?
      send_download(path, oid)
    elsif existing_file_requested_as_html?
      # TODO: the query_string check should be done in the iri router
      if request.query_string.present?
        ontology = resource.ontologies.first.children.where(name: request.query_string).first
        redirect_to [repository, ontology]
      end
    else
      send_download(path, oid)
    end
  end

  def download
    send_download(path, oid)
  end

  def entries_info
    render json: repository.entries_info(oid, path)
  end

  def diff
    @message = repository.commit_message(oid)
    @changed_files = repository.changed_files(oid)
  end

  def history
    @per_page = 25
    page = @page = params[:page].nil? ? 1 : params[:page].to_i
    offset = page > 0 ? (page - 1) * @per_page : 0

    @ontology = repository.primary_ontology(path)

    if repository.empty?
      @commits = []
    else
      @current_file = repository.get_file(path, oid) if path && !repository.dir?(path)
      @commits = repository.commits(start_oid: oid, path: path, offset: offset, limit: @per_page)
    end
  end

  def new
    @repository_file = resource_class.build(params.merge(user: current_user))
  end

  def create
    @repository_file = resource_class.create(params.merge(user: current_user))
    if resource.valid?
      flash[:success] = "Successfully saved the uploaded file."
      if ontology = repository.ontologies.with_path(resource.target_path).without_parent.first
        redirect_to edit_repository_ontology_path(repository, ontology)
      else
        redirect_to fancy_repository_path(repository, path: resource.target_path)
      end
    else
      render :new
    end
  end

  def update
    @repository_file = resource_class.create(params.merge(user: current_user))
    if resource.valid?
      flash[:success] = "Successfully changed the file."
      redirect_to fancy_repository_path(repository, path: resource.target_path)
    else
      render :show
    end
  end

  protected

  def resource
    @repository_file ||= resource_class.find_with_path(params)
  end

  def repository
    @repository ||= Repository.find_by_path!(params[:repository_id])
  end

  def ref
    params[:ref] || 'master'
  end

  def check_read_permissions
    authorize! :show, repository
  end

  def check_write_permissions
    authorize! :write, repository
  end

  def send_download(path, oid)
    render text: repository.get_file(path, oid).content,
           content_type: Mime::Type.lookup('application/force-download')
  end

  def commit_id
    @commit_id ||= repository.commit_id(params[:ref])
  end

  def oid
    @oid ||= commit_id[:oid] unless commit_id.nil?
  end

  def branch_name
    commit_id[:branch_name]
  end

  def path
    params[:path]
  end

  def owl_api_header_in_accept_header?
    # OWL API sends those two http accept headers in different requests:
    # application/rdf+xml, application/xml; q=0.5, text/xml; q=0.3, */*; q=0.2
    # text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2
    # The latter conflicts with what browsers send.
    accepts = request.accepts.compact
    (accepts.present? && accepts.first != Mime::HTML) ||
      accepts[0..2] == [Mime::HTML, Mime::GIF, Mime::JPEG]
  end

  def existing_file_requested_as_html?
    request.accepts.first == Mime::HTML || !resource.file?
  end

end
