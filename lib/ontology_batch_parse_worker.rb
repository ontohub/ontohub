class OntologyBatchParseWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(versions)
    return if versions.empty?

    version_id, opts = versions.shift
    version = OntologyVersion.find(version_id)

    opts.each do |method_name, value|
      version.send(:"#{method_name}=", value)
    end

    version.parse

    self.perform_async(versions)
  end
end
