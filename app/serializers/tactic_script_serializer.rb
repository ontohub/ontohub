class TacticScriptSerializer < ApplicationSerializer
  attributes :time_limit, :extra_options

  def extra_options
    object.extra_options.map(&:option)
  end
end
