require 'spec_helper'

describe Semaphore do
  let!(:key) { :semaphore_key }

  it 'is not locked before another thread uses the key' do
    expect(Semaphore.locked?(key)).to be(false)
  end

  it 'is locked while another thread uses the key' do
    skip 'This hangs the test suite because of celluloid.'
    # 0.125 seconds should be enough for the second thread to run
    semaphore_locked = false
    process_lock = ForkBreak::Process.new do |breakpoints|
      Semaphore.exclusively(key, expiration: 1) do
        breakpoints << :after_locking
      end
    end
    process_check = ForkBreak::Process.new do |_breakpoints|
      semaphore_locked = Semaphore.locked?(key, expiration: 1)
    end
    process_lock.run_until(:after_locking).wait
    process_check.finish.wait
    process_lock.finish.wait

    expect(semaphore_locked).to be(true)
  end

  it 'is not locked after another thread uses the key' do
    Semaphore.exclusively(key) { nil }
    expect(Semaphore.locked?(key)).to be(false)
  end

  it 'returns the block result on "exclusively"' do
    expect(Semaphore.exclusively(@key) { :result }).to eq(:result)
  end
end
