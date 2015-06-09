class SettingsValidator
  class SettingsValidator::ValidationError < ::StandardError; end

  def validate!
    settings_validations_wrapper = SettingsValidationWrapper.new
    unless settings_validations_wrapper.valid?
      plain_errors = settings_validations_wrapper.errors.messages
      formatted_errors = format_errors(plain_errors)
      print_errors(formatted_errors)
      exit
    end
  end

  protected

  def print_errors(formatted_errors)
    $stderr.puts 'The settings are invalid. Please check your settings*.yml'
    $stderr.puts
    formatted_errors.each { |error| $stderr.puts error }
    $stderr.puts
    $stderr.puts 'Stopping the application.'
  end

  def format_errors(errors)
    errors.map { |key, messages| format_error(key, messages) }
  end

  def format_error(key, messages)
    category, key_portions = key_info(key)
    <<-MESSAGE.strip_heredoc
      #{format_key(key_portions)}:
      #{format_messages(messages)}
    MESSAGE
  end

  def key_info(key)
    category, *portions = key.to_s.split('__')
    [category.to_sym, portions]
  end

  def format_key(portions)
    portions.join('.')
  end

  def format_messages(messages)
    messages.map { |message| format_message(message) }.join("\n")
  end

  def format_message(message)
    "  #{message}"
  end
end
