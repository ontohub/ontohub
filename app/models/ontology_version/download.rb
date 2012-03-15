module OntologyVersion::Download
  extend ActiveSupport::Concern
  
  included do
    @queue = :download
    after_create :download_async, :if => :source_uri?
  end

  def download
    raise ArgumentError.new('No source_uri set.') unless source_uri?

    update_state! :downloading

    do_or_set_failed do
      self.remote_raw_file_url = self.source_uri
      save!
    end

    self.async :parse
  end
  
  def download_async
    async :download
  end
end
