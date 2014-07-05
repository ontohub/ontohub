# encoding: utf-8
module TimestampHelper

  def timestamp(time)
    time = time.created_at if time.respond_to?(:created_at)
    content_tag :span, time.iso8601, class: :timestamp
  end

end
