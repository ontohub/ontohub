class FiletypesController < ApplicationController
  def create
    render json: filetype_json
  end

  protected

  def filetype
    @filetype ||= Hets::FiletypeCaller.new(HetsInstance.choose).
      call(params[:iri])
  end

  def filetype_json
    iri, mime_type = filetype.split(': ')
    {
      iri: iri,
      mime_type: mime_type,
      extension: FileExtensionMimeTypeMapping.
        find_by_mime_type(mime_type).try(:file_extension)
    }
  end
end
