require 'spec_helper'

describe 'OopsRequest::States' do
  let(:oops_request) { create :oops_request }
  before { allow(oops_request).to receive(:execute_and_save) }

  it 'have state pending' do
    expect(oops_request.state).to eq('pending')
  end

  context 'with an error' do
    let(:message) { 'error from stub' }
    before do
      allow(oops_request).to receive(:execute_and_save).
        and_raise(Oops::Error, message)
      begin
        oops_request.run
      rescue Oops::Error
      end
    end

    it 'have state failed' do
      expect(oops_request.state).to eq('failed')
    end

    it 'have the error message' do
      expect(oops_request.last_error).to eq(message)
    end
  end

  context 'without an error' do
    before { oops_request.run }

    it 'have state done' do
      expect(oops_request.state).to eq('done')
    end

    it 'have no error' do
      expect(oops_request.last_error).to be_nil
    end
  end
end
