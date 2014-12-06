require 'spec_helper'

describe 'OopsRequest::States' do
  let(:request) { create :oops_request }
  before { allow(request).to receive(:execute_and_save) }

  it 'have state pending' do
    expect(request.state).to eq('pending')
  end

  context 'with an error' do
    let(:message) { 'error from stub' }
    before do
      allow(request).to receive(:execute_and_save).
        and_raise(Oops::Error, message)
      begin
        request.run
      rescue Oops::Error
      end
    end

    it 'have state failed' do
      expect(request.state).to eq('failed')
    end

    it 'have the error message' do
      expect(request.last_error).to eq(message)
    end
  end

  context 'without an error' do
    before { request.run }

    it 'have state done' do
      expect(request.state).to eq('done')
    end

    it 'have no error' do
      expect(request.last_error).to be_nil
    end
  end
end
