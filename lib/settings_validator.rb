class SettingsValidator
  class SettingsValidator::ValidationError < ::StandardError; end

  def validate!
    settings_validations_wrapper = SettingsValidationWrapper.new
    unless settings_validations_wrapper.valid?
      raise ValidationError.new(settings_validations_wrapper.errors.
        messages.inspect)
    end
  end
end
