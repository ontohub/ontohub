require 'spec_helper'

describe HetsInstance do
  let(:general_version) { Hets.minimum_version.to_s }
  let(:specific_version) { Hets.minimum_revision.to_s }
  let(:hets_instance) { create_local_hets_instance }

  context 'when registering a hets instance' do
    context 'wrt. to update-jobs' do
      before do
        stub_request(:get, %r{http://localhost:8\d{3}/version}).
          to_return(status: 200,
                    body: "v#{general_version}, #{specific_version}",
                    headers: {})
        hets_instance
      end

      it 'should create a job' do
        expect(HetsInstanceWorker.jobs.count).to eq(1)
      end

      it 'should have a job with the correct attributes' do
        expect(HetsInstanceWorker.jobs.first).
          to include('args' => [hets_instance.id])
      end
    end
  end

  context 'when choosing a hets instance' do
    context 'and there is no hets instance recorded' do
      it 'should raise the appropriate error' do
        expect { HetsInstance.choose! }.
          to raise_error(HetsInstance::NoRegisteredHetsInstanceError)
      end
    end

    context 'and there is no acceptable hets instance' do
      let(:hets_instance) { create_local_hets_instance }

      before do
        stub_request(:get, %r{http://localhost:8\d{3}/version}).
          to_return(status: 500, body: "", headers: {})
        hets_instance
      end

      it 'should raise the appropriate error' do
        expect { HetsInstance.choose! }.
          to raise_error(HetsInstance::NoSelectableHetsInstanceError)
      end
    end

    context 'and there is an acceptable hets instance' do
      before do
        stub_request(:get, %r{http://localhost:8\d{3}/version}).
          to_return(status: 200,
                    body: "v#{general_version}, #{specific_version}",
                    headers: {})
        hets_instance
      end

      it 'should return that hets instance' do
        expect(HetsInstance.choose!).to eq(hets_instance)
      end
    end

    context 'load balancing' do
      before do
        stub_request(:get, %r{http://localhost:8\d{3}/version}).
          to_return({status: 200,
                     body: "v#{general_version}, #{specific_version}",
                     headers: {}})
      end

      context 'free, force-free and busy are available' do
        let!(:free) { create :hets_instance, state: 'free' }
        let!(:force_free) { create :hets_instance, state: 'force-free' }
        let!(:busy) { create :hets_instance, state: 'busy' }

        it 'choose! chose the free instance' do
          expect(HetsInstance.choose!.uri).to eq(free.uri)
        end

        it 'with_instance! returns the result of its block' do
          expect(HetsInstance.with_instance! { |_i| :result }).to be(:result)
        end

        it 'with_instance! chose the free instance' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.uri).to eq(free.uri)
        end

        it 'choose! marks it as busy' do
          instance = HetsInstance.choose!
          expect(instance.state).to eq('busy')
        end

        it 'choose! does not increase the queue size' do
          instance = HetsInstance.choose!
          expect(instance.queue_size).to eq(0)
        end

        it 'with_instance! does not increase the queue size during the work' do
          HetsInstance.with_instance! do |instance|
            expect(instance.queue_size).to eq(0)
          end
        end

        it 'with_instance! does not increase the queue size after the work' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.queue_size).to eq(0)
        end

        it 'finish_work! marks it as free' do
          instance = HetsInstance.choose!
          instance.finish_work!
          expect(instance.state).to eq('free')
        end

        it 'finish_work! does not decrease the queue size' do
          instance = HetsInstance.choose!
          instance.finish_work!
          expect(instance.queue_size).to eq(0)
        end

        it 'with_instance! marks it as busy during the work' do
          HetsInstance.with_instance! do |instance|
            expect(instance.state).to eq('busy')
          end
        end

        it 'with_instance! marks it as free after the work' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.state).to eq('free')
        end
      end

      context 'force-free and busy are available' do
        let!(:force_free0) { create :hets_instance, state: 'force-free', queue_size: 0 }
        let!(:force_free1) { create :hets_instance, state: 'force-free', queue_size: 1 }
        let!(:busy) { create :hets_instance, state: 'busy' }

        it 'choose! chose the force-free instance with queue size 0' do
          expect(HetsInstance.choose!.uri).to eq(force_free0.uri)
        end

        it 'with_instance! chose the force-free instance with queue size 0' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.uri).to eq(force_free0.uri)
        end

        it 'choose! marks it as busy' do
          instance = HetsInstance.choose!
          expect(instance.state).to eq('busy')
        end

        it 'choose! increases the queue size' do
          instance = HetsInstance.choose!
          expect(instance.queue_size).to eq(1)
        end

        it 'with_instance! increases the queue size during the work' do
          HetsInstance.with_instance! do |instance|
            expect(instance.queue_size).to eq(1)
          end
        end

        it 'with_instance! does not increase the queue size after the work' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.queue_size).to eq(0)
        end

        it 'finish_work! marks it as free' do
          instance = HetsInstance.choose!
          instance.finish_work!
          expect(instance.state).to eq('free')
        end

        it 'finish_work! decreases the queue size' do
          instance = HetsInstance.choose!
          instance.finish_work!
          expect(instance.queue_size).to eq(0)
        end

        it 'with_instance! marks it as busy during the work' do
          HetsInstance.with_instance! do |instance|
            expect(instance.state).to eq('busy')
          end
        end

        it 'with_instance! marks it as free after the work' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.state).to eq('free')
        end
      end

      context 'only busy are available' do
        let!(:busy0) { create :hets_instance, state: 'busy', queue_size: 0 }
        let!(:busy1) { create :hets_instance, state: 'busy', queue_size: 1 }

        it 'choose! chose the busy instance with queue size 0' do
          expect(HetsInstance.choose!.uri).to eq(busy0.uri)
        end

        it 'with_instance! chose the busy instance with queue size 0' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.uri).to eq(busy0.uri)
        end

        it 'choose! marks it as busy' do
          instance = HetsInstance.choose!
          expect(instance.state).to eq('busy')
        end

        it 'choose! increases the queue size' do
          instance = HetsInstance.choose!
          expect(instance.queue_size).to eq(1)
        end

        it 'with_instance! increases the queue size during the work' do
          HetsInstance.with_instance! do |instance|
            expect(instance.queue_size).to eq(1)
          end
        end

        it 'with_instance! does not increase the queue size after the work' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.queue_size).to eq(0)
        end

        it 'finish_work! marks it as free' do
          instance = HetsInstance.choose!
          instance.finish_work!
          expect(instance.state).to eq('free')
        end

        it 'finish_work! decreases the queue size' do
          instance = HetsInstance.choose!
          instance.finish_work!
          expect(instance.queue_size).to eq(0)
        end

        it 'with_instance! marks it as busy during the work' do
          HetsInstance.with_instance! do |instance|
            expect(instance.state).to eq('busy')
          end
        end

        it 'with_instance! marks it as free after the work' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.state).to eq('free')
        end
      end

      context 'only very busy are available' do
        let!(:busy0) { create :hets_instance, state: 'busy', queue_size: 1 }
        let!(:busy1) { create :hets_instance, state: 'busy', queue_size: 2 }

        it 'choose! chose the busy instance with queue size 0' do
          expect(HetsInstance.choose!.uri).to eq(busy0.uri)
        end

        it 'with_instance! chose the busy instance with queue size 0' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.uri).to eq(busy0.uri)
        end

        it 'choose! marks it as busy' do
          instance = HetsInstance.choose!
          expect(instance.state).to eq('busy')
        end

        it 'choose! increases the queue size' do
          instance = HetsInstance.choose!
          expect(instance.queue_size).to eq(2)
        end

        it 'with_instance! increases the queue size during the work' do
          HetsInstance.with_instance! do |instance|
            expect(instance.queue_size).to eq(2)
          end
        end

        it 'with_instance! does not increase the queue size after the work' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.queue_size).to eq(1)
        end

        it 'finish_work! still marks it as busy' do
          instance = HetsInstance.choose!
          instance.finish_work!
          expect(instance.state).to eq('busy')
        end

        it 'finish_work! decreases the queue size' do
          instance = HetsInstance.choose!
          instance.finish_work!
          expect(instance.queue_size).to eq(1)
        end

        it 'with_instance! marks it as busy during the work' do
          HetsInstance.with_instance! do |instance|
            expect(instance.state).to eq('busy')
          end
        end

        it 'with_instance! still marks it as free after the work' do
          chosen = nil
          HetsInstance.with_instance! { |instance| chosen = instance }
          expect(chosen.state).to eq('busy')
        end
      end
    end
  end

  context 'force-freeing an instance' do
    before do
      stub_request(:get, %r{http://localhost:8\d{3}/version}).
        to_return(status: 500, body: "", headers: {})
    end

    context 'set_busy!' do
      let!(:hets_instance) { create :hets_instance, state: 'free' }

      before do
        allow(HetsInstanceForceFreeWorker).to receive(:perform_in)
      end

      it 'calls the HetsInstanceForceFreeWorker' do
        hets_instance.set_busy!
        expect(HetsInstanceForceFreeWorker).
          to have_received(:perform_in).
          with(HetsInstance::FORCE_FREE_WAITING_PERIOD, hets_instance.id)
      end
    end

    context 'set_force_free!' do
      context 'on a free instance' do
        let!(:hets_instance) { create :hets_instance, state: 'free' }
        before { hets_instance.set_force_free! }

        it 'is a no-op' do
          expect(hets_instance.state).to eq('free')
        end
      end

      context 'on a force-free instance' do
        let!(:hets_instance) { create :hets_instance, state: 'force-free' }
        before { hets_instance.set_force_free! }

        it 'is a no-op' do
          expect(hets_instance.state).to eq('force-free')
        end
      end

      context 'on a busy instance' do
        let!(:hets_instance) { create :hets_instance, state: 'busy' }
        before { hets_instance.set_force_free! }

        it 'change the state' do
          expect(hets_instance.state).to eq('force-free')
        end
      end
    end
  end

  context 'when creating a hets instance' do
    context 'and it has a reachable uri' do
      before do
        stub_request(:get, %r{http://localhost:8\d{3}/version}).
          to_return(status: 200,
                    body: "v#{general_version}, #{specific_version}",
                    headers: {})
      end

      it 'should have a up-state of true' do
        expect(hets_instance.up).to be(true)
      end

      it 'should have a non-null version' do
        expect(hets_instance.version).to_not be(nil)
      end

      it 'should have a correct general_version' do
        expect(hets_instance.general_version).to eq(general_version)
      end

      it 'should have a correct specific version' do
        expect(hets_instance.specific_version).to eq(specific_version)
      end

    end

    context 'and it has a non-reachable uri' do
      before do
        stub_request(:get, %r{http://localhost:8\d{3}/version}).
          to_return(status: 500, body: "", headers: {})
      end

      it 'should have a up-state of false' do
        expect(hets_instance.up).to be(false)
      end

      it 'should have a nil version' do
        expect(hets_instance.version).to be(nil)
      end

      it 'should have a nil general_version' do
        expect(hets_instance.general_version).to be(nil)
      end

      it 'should have a nil specific version' do
        expect(hets_instance.specific_version).to be(nil)
      end
    end
  end
end
