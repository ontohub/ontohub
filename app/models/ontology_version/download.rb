module OntologyVersion::Download
  extend ActiveSupport::Concern
  
  included do
    @queue = :download
    after_create :download_async, :if => :source_url?
  end

  def download
    raise ArgumentError.new('No source_url set.') unless source_url?

    update_state! :downloading

    do_or_set_failed do
      self.remote_raw_file_url = self.source_url
      save!
    end

    self.async :parse
  end
  
  def download_async
    async :download
  end
end
