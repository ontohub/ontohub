require 'spec_helper'

describe HetsInstance do
  let(:general_version) { Hets.minimum_version.to_s }
  let(:specific_version) { Hets.minimum_revision.to_s }
  let(:hets_instance) { create :local_hets_instance }

  context 'when choosing a hets instance' do
    context 'and there is no hets instance recorded' do
      it 'should raise the appropriate error' do
        expect { HetsInstance.choose! }.
          to raise_error(HetsInstance::NoRegisteredHetsInstanceError)
      end
    end

    context 'and there is no acceptable hets instance' do
      let(:hets_instance) { create :local_hets_instance }

      before do
        stub_request(:get, "http://localhost:8000/version").
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
        stub_request(:get, "http://localhost:8000/version").
          to_return(status: 200,
                    body: "v#{general_version}, #{specific_version}",
                    headers: {})
        hets_instance
      end

      it 'should return that hets instance' do
        expect(HetsInstance.choose!).to eq(hets_instance)
      end
    end
  end

  context 'when creating a hets instance' do
    context 'and it has a reachable uri' do
      before do
        stub_request(:get, "http://localhost:8000/version").
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
        stub_request(:get, "http://localhost:8000/version").
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
