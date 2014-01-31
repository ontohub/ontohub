# A wrapper for IO.popen that returns the combined stdout and stderr.
# An exception is thrown if the subprocess exists with non-zero.
module Subprocess

  class Error < ::StandardError
    attr_reader :status, :output
    def initialize(args, status, output)
      super "Subprocess #{args.inspect} exited with status #{status}:\n#{output}"
      @status = status
      @output = output
    end
  end

  # Runs a command
  # The optional hash contains environment variables
  def self.run(*args)
    env    = stringify_keys(args.extract_options!)
    args   = args.map(&:to_s)
    output = IO.popen env, args, err: [:child, :out], &:read
    status = $?.exitstatus

    if status != 0
      raise Error.new args, status, output
    end

    output
  end

  private

  def self.stringify_keys(hash)
    hash.reduce({}) do |h, (key, value)|
      h[key.to_s] = value
      h
    end
  end

end
