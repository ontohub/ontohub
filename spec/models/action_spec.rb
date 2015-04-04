require 'spec_helper'

describe Action do
  context '#eta' do
    let(:action) { create :action }
    let(:target) { action.created_at + action.eta }

    it 'should return the initial eta at creation time' do
      expect(action.eta(action.created_at).to_i).
        to eq(action.initial_eta)
    end

    it 'should return correct eta' do
      expect(action.eta(target - 1).to_i).to eq(1)
    end

    it 'should return 0 if the eta has been reached' do
      expect(action.eta(target + 5.minutes)).to eq(0)
    end
  end

  context '#status' do
    let(:action) { create :action, resource: resource }
    let(:status) { 'some status' }

    context 'on resource with state' do
      let(:resource) { mock_model("Resource", state: status) }

      it 'should return the correct status' do
        expect(action.status).to eq(status)
      end
    end

    context 'on resource with status' do
      let(:resource) { mock_model("Resource", status: status) }

      it 'should return the correct status' do
        expect(action.status).to eq(status)
      end
    end

    context 'on resource w/o anything' do
      let(:resource) { mock_model("Resource") }

      it 'should complain with an error' do
        expect { action.status }.to raise_error(NoMethodError)
      end
    end

    context 'without a resource' do
      let(:resource) { nil }
      let(:status) { 'waiting' }

      it 'should return the correct status' do
        expect(action.status).to eq(status)
      end
    end
  end
end
