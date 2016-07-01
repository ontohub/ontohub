class BaseWorker
  include Sidekiq::Worker

  # Because of the JSON-Parsing the hash which contains the try_count will
  # contain the try_count key as a string and not as a symbol (which is
  # necessary for the keyword-style to work).  This method is usually called
  # inside of `perform` of a specific worker.
  def establish_arguments(args, try_count: 1)
    if args.last.is_a?(Hash) && args.last['try_count']
      hash = args.pop
      @try_count = hash['try_count']
    else
      @try_count = try_count
    end
    @args = args
  end

end
