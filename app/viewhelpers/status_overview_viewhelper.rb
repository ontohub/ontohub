class StatusOverviewViewhelper < ViewhelperBase
  include WrappingRedis

  def ontology_count_by_state
    fill_with_missing_states(Ontology.group(:state).count, 0)
  end

  def processing_iris_count
    redis.smembers(ConcurrencyBalancer::REDIS_KEY).size
  end

  private
  def fill_with_missing_states(hash, default)
    Ontology::States::STATES.each do |state|
      hash[state.to_s] ||= default
    end
    hash
  end

end
