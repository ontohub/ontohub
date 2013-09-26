class RepositoriesController < ApplicationController

  inherit_resources
  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index, :show]

  def files
    @path = params[:path]

    commit_id = @repository.commit_id(params[:oid])
    @oid = commit_id[:oid]
    @branch_name = commit_id[:branch_name]

    @info = @repository.path_info(params[:path], @oid)

    raise Repository::FileNotFoundError, @path if @info.nil?
    
    case @info[:type]
    when :raw
      render text: @repository.read_file(@path, @oid)[:content],
             content_type: Mime::Type.lookup('application/force-download')
    when :file_base
      @file = @repository.read_file(@info[:entry][:path], params[:oid])
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
