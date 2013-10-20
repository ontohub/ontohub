# A wrapper for IO.popen that returns the combined stdout and stderr.
# An exception is thrown if the subprocess exists with non-zero.
module Subprocess

  class Error < ::Exception
    attr_reader :status, :output
    def initialize(args, status, output)
      super "Subprocess #{args.inspect} exited with status #{status}:\n#{output}"
      @status = status
      @output = output
    end
  end

  def self.run(*args)
    output = IO.popen args, err: [:child, :out] do |ls_io|
      ls_io.read
    end

    status = $?.exitstatus

    if status != 0
      raise Error.new args, status, output
    end

    output
  end

end