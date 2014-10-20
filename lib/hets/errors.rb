module Hets
  module Errors
    class HetsError < ::StandardError; end

    class ExecutionError < HetsError; end
    class DeploymentError < HetsError; end

    class VersionOutdatedError < DeploymentError; end
    class ConfigDateFormatError < DeploymentError; end
    class VersionDateFormatError < DeploymentError; end
    class InvalidHetsVersionFormatError < DeploymentError; end

    class HetsArgumentError < HetsError; end

    class InactiveInstanceError < HetsArgumentError; end
  end
end
