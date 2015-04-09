class TacticScript < ActiveRecord::Base
  belongs_to :proof_attempt
  has_many :extra_options, class_name: TacticScriptExtraOption.to_s
  attr_accessible :time_limit 

  def to_s
    {time_limit: time_limit,
     extra_options: extra_options.map(&:option)}.to_json
  end
end
