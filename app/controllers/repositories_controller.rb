class RepositoriesController < ApplicationController

  inherit_resources
  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index, :show]

  def files
    @path = params[:path]

    commit_id = @repository.commit_id(params[:oid])
    @oid = commit_id[:oid]
    @branch_name = commit_id[:branch_name]

    @is_head = @repository.is_head?(@oid)

    @info = @repository.path_info(params[:path], @oid)

    raise Repository::FileNotFoundError, @path if @info.nil?
    
    case @info[:type]
    when :raw
      render text: @repository.read_file(@path, params[:oid]),
             content_type: Mime::Type.lookup('application/force-download')
    when :file_base
      @content = @repository.read_file(@info[:entry][:path], params[:oid])
    when :file_base_ambiguous
      @info[:entries]
    end
  end
end
