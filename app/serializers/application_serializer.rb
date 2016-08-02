class ApplicationSerializer < ActiveModel::Serializer
  def urls
    Rails.application.routes.url_helpers
  end
end
