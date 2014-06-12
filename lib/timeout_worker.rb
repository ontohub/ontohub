class TimeoutWorker < BaseWorker
  class Error < ::StandardError; end
  class TimeOutNotSetError < Error; end

  include Sidekiq::Worker

  def perform(start_time, ontology_version_id)
    if timeout_reached?(Time.at(start_time))
      version = OntologyVersion.find(ontology_version_id)
      version.update_state!('failed', "The job reached the timeout limit of #{timeout_limit} hours.")
    end
  end

  def timeout_limit
    raise TimeOutNotSetError unless Settings.ontology_parse_timeout
    Settings.ontology_parse_timeout
  end

  def timeout_reached?(start_time)
    one_hour = 3600
    timeout_time = start_time + timeout_limit * one_hour
    Time.now >= timeout_time
  end

end
