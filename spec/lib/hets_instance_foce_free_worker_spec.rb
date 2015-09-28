require 'spec_helper'

describe HetsInstanceForceFreeWorker do
  before do
    stub_request(:get, %r{http://localhost:8\d{3}/version}).
      to_return(status: 500, body: "", headers: {})
  end

  context 'on a free instance' do
    let!(:hets_instance) { create :hets_instance, state: 'free' }
    before do
      Sidekiq::Testing.inline! do
        HetsInstanceForceFreeWorker.new.perform(hets_instance.id)
      end
    end

    it 'is a no-op' do
      expect(hets_instance.reload.state).to eq('free')
    end
  end

  context 'on a force-free instance' do
    let!(:hets_instance) { create :hets_instance, state: 'force-free' }
    before do
      Sidekiq::Testing.inline! do
        HetsInstanceForceFreeWorker.new.perform(hets_instance.id)
      end
    end

    it 'is a no-op' do
      expect(hets_instance.reload.state).to eq('force-free')
    end
  end

  context 'on a busy instance' do
    let!(:hets_instance) { create :hets_instance, state: 'busy' }
    before do
      Sidekiq::Testing.inline! do
        HetsInstanceForceFreeWorker.new.perform(hets_instance.id)
      end
    end

    it 'change the state' do
      expect(hets_instance.reload.state).to eq('force-free')
    end
  end
end
