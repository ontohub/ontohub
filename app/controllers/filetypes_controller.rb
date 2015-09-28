class FiletypesController < ApplicationController
  def create
    render json: filetype_json
  rescue Hets::HetsError
    render json: {status: 415, message: 'Media Type not supported'},
           status: 415
  end

  protected

  def filetype
    HetsInstance.with_instance! do |hets_instance|
      @filetype ||= Hets::FiletypeCaller.new(hets_instance).call(params[:iri])
    end
  end

  def filetype_json
    iri, mime_type = filetype.split(': ')
    {
      status: 200,
      message: '',
      iri: iri,
      mime_type: mime_type,
      extension: FileExtensionMimeTypeMapping.
        find_by_mime_type(mime_type).try(:file_extension),
    }
  end
end
