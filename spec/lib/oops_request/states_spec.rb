require 'spec_helper'

describe 'OopsRequest::States' do
  context 'new oops request' do
    let(:request) { create :oops_request }
    before { allow_any_instance_of(OopsRequest).to(receive(:async_run)) }

    it 'be pending' do
      expect(request.state).to eq('pending')
    end

    context 'aftert processed with error' do
      let(:message) { 'some error message' }
      before do
        allow_any_instance_of(OopsRequest).to(receive(:execute_and_save).
          and_raise(Oops::Error, message))
      end

      it 'raises error' do
        allow_any_instance_of(OopsRequest).to(receive(:execute_and_save).
          and_raise(Oops::Error, message))
        expect { request.run }.to raise_error(Oops::Error)
      end

      context 'after run' do
        before do
          begin
            request.run
          rescue Oops::Error
          end
        end

        it 'set state to failed' do
          expect(request.state).to eq('failed')
        end

        it 'state the error message' do
          expect(request.last_error).to eq(message)
        end
      end
    end

    context 'aftert processed without error' do
      before do
        allow_any_instance_of(OopsRequest).to receive(:execute_and_save)
        request.run
      end

      it 'set state to done' do
        expect(request.state).to eq('done')
      end

      it 'not have a errors message' do
        expect(request.last_error).to be_nil
      end
    end
  end
end
