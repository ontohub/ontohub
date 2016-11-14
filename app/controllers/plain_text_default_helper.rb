module PlainTextDefaultHelper
  extend ActiveSupport::Concern

  included do
    before_filter :set_format
  end

  def set_format
    request.format = :text unless request.format.to_sym == :json
  end
end
