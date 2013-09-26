class RepositoriesController < ApplicationController

  inherit_resources
  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index, :show]

  def files
    commit_id = @repository.commit_id(params[:oid])
    @oid = commit_id[:oid]
    @branch_name = commit_id[:branch_name]
    @path = params[:path]
    @info = @repository.path_info(params[:path], @oid)

    raise Repository::FileNotFoundError, params[:path] if @info.nil?
    
    if request.format == 'text/html' || @info[:type] != :file
      case @info[:type]
      when :file
        @file = @repository.read_file(@path, params[:oid])
      when :file_base 
        # TODO: redirect to ontology view instead of rendering file view
        @path = @info[:entry][:path]
        @file = @repository.read_file(@path, params[:oid])
      end
    else
      render text: @repository.read_file(@path, @oid)[:content],
             content_type: Mime::Type.lookup('application/force-download')
    end
  end

  def entries_info
    render json: @repository.entries_info(@oid, params[:path])
  end

  def diff
    @oid = @repository.commit_id(params[:oid])[:oid]
    @changed_files = @repository.changed_files(@oid)
  end

  def history
    @path = params[:path]
    @oid = @repository.commit_id(params[:oid])[:oid]
    @current_file = @repository.read_file(@path, @oid) if @path
    @commits = @repository.commits(@oid, @path)
  end
end
