module ApplicationHelper

  def admin?
    current_user.try(:admin?)
  end

  def context_pane
    if params[:controller] == 'home'
      'shared/user_repositories'
    elsif params[:action] != 'index'
      false
    elsif %w[categories logics links ontologies].include? params[:controller]
      'shared/user_ontologies' unless in_repository?
    elsif params[:controller] == 'repositories'
      'shared/user_repositories'
    else
      false
    end
  end

  def cover_visible?
    params[:controller] == 'home' && !user_signed_in?
  end

  def in_repository?
    params[:repository_id] || params[:controller] == 'repositories'
  end

  def resource_chain
    return @resource_chain if @resource_chain

    if params[:logic_id]
      @resource_chain = []
      return @resource_chain      
    end

    if !params[:repository_id] && !(params[:controller] == 'repositories' && params[:id])
      @resource_chain = []
      return @resource_chain
    end

    @resource_chain = [ Repository.find_by_path!( controller_name=='repositories' ? params[:id] : params[:repository_id] )]
    
    if id = params[:commit_reference_id]
      @resource_chain << CommitReference.new(id)
    end

    if id = (controller_name=='ontologies' ? params[:id] : params[:ontology_id])
      @resource_chain << Ontology.find(id)
    end

    @resource_chain
  end

  def display_commit?
    !! Settings.display_head_commit
  end

  def display_commit
    # try to read the HEAD from the Git repository
    $commit_oid ||= begin
      path = Rails.root.join(".git")
      Subprocess.run(*%w(git rev-parse --short HEAD), GIT_DIR: path.to_s).strip if path.exist?
    end

    # try to read the revision from file
    $commit_oid ||= begin
      path = Rails.root.join("REVISION")
      path.read.strip if path.exist?
    end

    $commit_oid ||= 'unknown'
  end

end
