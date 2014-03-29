require 'spec_helper'

describe ConcurrencyBalancer do

  let(:balancer) { ConcurrencyBalancer.new }
  let(:redis) { ConcurrencyBalancer::RedisWrapper.new }

  before(:each) do
    redis.del ConcurrencyBalancer::REDIS_KEY
    redis.del ConcurrencyBalancer::SEQUENTIAL_LOCK_KEY
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

  context 'using the sequential lock' do
    it 'should fail when lock is taken' do
      redis.sadd(ConcurrencyBalancer::SEQUENTIAL_LOCK_KEY, true)
      expect { ConcurrencyBalancer.sequential_lock(&:+) }.
        to raise_error(ConcurrencyBalancer::AlreadyLockedError)
    end

    it "should work, when the lock isn't taken" do
      expect { ConcurrencyBalancer.sequential_lock { } }.
        not_to raise_error
    end

    it "should forward inner block errors when the lock isn't taken" do
      expect { ConcurrencyBalancer.sequential_lock { raise ArgumentError } }.
        to raise_error(ArgumentError)
    end

    it "should still release the lock on internal errors" do
      expect { ConcurrencyBalancer.sequential_lock { raise ArgumentError } }.
        to raise_error(ArgumentError)
      expect(redis.sismember ConcurrencyBalancer::REDIS_KEY, 'iri').to be_false
    end
  end

end
