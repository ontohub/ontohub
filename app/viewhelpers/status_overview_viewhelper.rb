class StatusOverviewViewhelper < ViewhelperBase
  include WrappingRedis

  def ontology_count_by_state
    states_map(0).merge!(Ontology.group(:state).count)
  end

  def processing_iris_count
    redis.smembers(ConcurrencyBalancer::REDIS_KEY).size
  end

  private
  def states_map(default)
    hash = {}
    Ontology::States::STATES.each do |state|
      hash[state] = default
    end
    hash
  end

end
