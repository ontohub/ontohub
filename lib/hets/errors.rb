module Hets
  module Errors
    class SyntaxError < ::StandardError; end
    class NotAHetsError < ::StandardError; end
    class HetsError < ::StandardError; end

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
