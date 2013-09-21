class RepositoriesController < ApplicationController

  inherit_resources
  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index, :show]

  def files
    @path = params[:path]
    @info = @repository.path_info params[:path]

    raise Repository::FileNotFoundError, @path if @info.nil?
    if @info[:type] == :raw
      render text: @repository.read_file(@path, params[:oid]),
             content_type: Mime::Type.lookup('application/force-download')
    end

    if @info[:type] == :file_base
      @content = @repository.read_file(@info[:entry][:path], params[:oid])
    end
  end

end
