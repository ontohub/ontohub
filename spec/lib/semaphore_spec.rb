require 'spec_helper'

describe Semaphore do
  # use a different key for each example to be safe
  before { |example| @key = example.description.parameterize }

  it 'is not locked before another thread uses the key' do
    expect(Semaphore.locked?(@key)).to be(false)
  end

  it 'is locked while another thread uses the key' do
    skip 'This hangs the test suite because of celluloid.'
    semaphore_locked = false
    process_lock = ForkBreak::Process.new do |breakpoints|
      Semaphore.exclusively(@key, expiration: 1) do
        breakpoints << :after_locking
      end
    end
    process_check = ForkBreak::Process.new do |_breakpoints|
      semaphore_locked = Semaphore.locked?(@key, expiration: 1)
    end
    process_lock.run_until(:after_locking).wait
    process_check.finish.wait
    process_lock.finish.wait

    expect(semaphore_locked).to be(true)
  end

  it 'is not locked after another thread uses the key' do
    Semaphore.exclusively(@key) { nil }
    expect(Semaphore.locked?(@key)).to be(false)
  end

  context 'instance' do
    let(:sema) { Semaphore.new(@key) }
    context 'using lock' do
      after { sema.unlock }

      it 'is locked after using lock' do
        sema.lock
        expect(sema.locked?).to be(true)
      end
    end

    it 'is not locked after using lock and unlock' do
      sema.lock
      sema.unlock
      expect(sema.locked?).to be(false)
    end
  end

  it 'returns the block result on "exclusively"' do
    expect(Semaphore.exclusively(@key) { :result }).to eq(:result)
  end
end
