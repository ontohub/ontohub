class OntologyBatchParseWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(try_count, versions)
    done = false

    return if versions.empty?

    version_id, opts = versions.head
    version = OntologyVersion.find(version_id)

    opts.each do |method_name, value|
      version.send(:"#{method_name}=", value)
    end

    version.parse
  rescue ConcurrencyBalancer::AlreadyProcessingError
    self.class.perform_async(try_count+1, versions)
    done = true
  ensure
    self.class.perform_async(1, versions.tail) unless versions.tail.empty? || done
  end
end
