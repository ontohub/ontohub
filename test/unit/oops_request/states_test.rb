require 'test_helper'

class OopsRequest::StatesTest < ActiveSupport::TestCase

  context 'new oops request' do
    setup do
      OopsRequest.any_instance.stubs(:async_run).once

      @request = FactoryGirl.create :oops_request
    end

    should 'be pending' do
      assert_equal "pending", @request.state
    end

    context 'aftert processed with error' do
      setup do
        @message = 'some error message'
        OopsRequest.any_instance.stubs(:execute_and_save).raises(Oops::Error, @message)
        assert_raises Oops::Error do
          @request.run
        end
      end

      should 'set state to failed' do
        assert_equal "failed", @request.state
      end

      should 'state the error message' do
        assert_equal @message, @request.last_error
      end
    end

    context 'aftert processed without error' do
      setup do
        OopsRequest.any_instance.stubs(:execute_and_save).once
        @request.run
      end

      should 'set state to done' do
        assert_equal "done", @request.state
      end

      should 'not have a errors message' do
        assert_nil @request.last_error
      end
    end

  end

end
