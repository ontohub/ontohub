require 'spec_helper'

describe ConcurrencyBalancer do

  let(:balancer) { ConcurrencyBalancer.new }
  let(:redis) { ConcurrencyBalancer::RedisWrapper.new }

  before(:each) do
    redis.del ConcurrencyBalancer::REDIS_KEY
  end

  context 'successfully marking an unmarked iri' do
    it 'should work' do
      expect { balancer.mark_as_processing_or_complain('iri') }.
        not_to raise_error
    end
  end

  context 'trying to mark a marked iri' do
    it 'should completely fail' do
      redis.sadd ConcurrencyBalancer::REDIS_KEY, 'iri'
      expect { balancer.mark_as_processing_or_complain('iri') }.
        to raise_error(ConcurrencyBalancer::AlreadyProcessingError)
    end
  end

  context 'successfully unmarking a marked iri' do
    it 'should work nicely' do
      redis.sadd ConcurrencyBalancer::REDIS_KEY, 'iri'
      expect { balancer.mark_as_finished_processing('iri') }.
        not_to raise_error
    end
  end

  context 'trying to unmark an unmarked iri' do
    it 'should completely fail' do
      expect { balancer.mark_as_finished_processing('iri') }.
        to raise_error(ConcurrencyBalancer::UnmarkedProcessingError)
    end
  end

  context 'marking an iri while unmarking another one' do
    it 'should be awesome' do
      redis.sadd ConcurrencyBalancer::REDIS_KEY, 'iri'
      expect { balancer.mark_as_processing_or_complain('second-iri', unlock_this_iri: 'iri') }.
        not_to raise_error
    end
  end

end
