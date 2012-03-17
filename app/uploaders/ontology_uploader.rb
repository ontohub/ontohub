class OntologyUploader < CarrierWave::Uploader::Base
  storage :file
  
  UPLOADS_DIR = Rails.env.test? ? "#{Rails.root}/tmp/uploads" : "uploads"
  
  def store_dir
    "#{UPLOADS_DIR}/#{model.ontology_id}/#{model.id}/#{mounted_as}"
  end

  def sha1
    ::Digest::SHA1.file(current_path).hexdigest
  end
end
