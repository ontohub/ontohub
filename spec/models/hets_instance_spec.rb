require 'spec_helper'

describe HetsInstance do
  context 'when creating a hets instance' do
    context 'and it has a reachable uri' do
      let(:general_version) { '0.99' }
      let(:specific_version) { '1409043198' }
      let(:hets_instance) { create :local_hets_instance }

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
        expect(hets_instance.version).to_not be_nil
      end

      it 'should have a correct general_version' do
        expect(hets_instance.general_version).to eq(general_version)
      end

      it 'should have a correct specific version' do
        expect(hets_instance.specific_version).to eq(specific_version)
      end

    end

    context 'and it has a non-reachable uri' do
      let(:hets_instance) { create :local_hets_instance }

      before do
        stub_request(:get, "http://localhost:8000/version").
          to_return(status: 500, body: "", headers: {})
      end

      it 'should have a up-state of false' do
        expect(hets_instance.up).to be(false)
      end

      it 'should have a nil version' do
        expect(hets_instance.version).to be_nil
      end

      it 'should have a nil general_version' do
        expect(hets_instance.general_version).to be_nil
      end

      it 'should have a nil specific version' do
        expect(hets_instance.specific_version).to be_nil
      end
    end
  end
end
