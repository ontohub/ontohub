class OntologyVersionOptions
  attr_reader :filepath, :pusher, :fast_parse, :do_not_parse, :previous_filepath

  def initialize(filepath, pusher, fast_parse: false, do_not_parse: false,
    previous_filepath: nil)
    @filepath = filepath
    @pusher = pusher
    @fast_parse = fast_parse
    @do_not_parse = do_not_parse
    @previous_filepath = previous_filepath
  end

  def pre_saving_filepath
    previous_filepath || filepath
  end
end
