module Hets
  module Errors
    class NotAHetsError < ::StandardError; end
    class HetsError < ::StandardError; end

    class ExecutionError < HetsError
      attr_reader :abort_execution

      def initialize(msg = nil, abort_execution: false)
        @abort_execution = abort_execution
        super(msg)
      end
    end

    class HetsFileError < HetsError; end

    class DeploymentError < HetsError; end

    class FiletypeNotDeterminedError < HetsError; end

    class VersionOutdatedError < DeploymentError; end
    class ConfigDateFormatError < DeploymentError; end
    class VersionDateFormatError < DeploymentError; end
    class InvalidHetsVersionFormatError < DeploymentError; end

    class HetsArgumentError < HetsError; end

    class InactiveInstanceError < HetsArgumentError; end
  end
end
