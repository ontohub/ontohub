module Users::RegistrationsHelper
  def api_key
    resource.api_keys.valid.first
  end

  def blank_api_key
    ApiKey.new(user: resource)
  end
end
