class FileRetriever
  include UriFetcher

  OPTION_PACK = {
    tempfile: {write_file: true, file_type: Tempfile},
    string: {}
  }

  def initialize(store_as: :tempfile)
    @store_as = store_as
  end

  def call(url)
    get_caller = GetCaller.new(url)
    get_caller.call(get_caller_options)
  end

  def get_caller_options
    OPTION_PACK[@store_as] || OPTION_PACK[:tempfile]
  end
end
