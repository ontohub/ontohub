class SettingsValidator
  class SettingsValidator::ValidationError < ::StandardError; end

  CONFIG_YML_FILES =
    "config/settings[.local].yml or config/settings/#{Rails.env}[.local].yml"
  CONFIG_INITIALIZER_FILES = "config/environments/#{Rails.env}[.local].rb"

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
    $stderr.puts "The settings are invalid. Please check your #{CONFIG_YML_FILES}"
    $stderr.puts 'The following errors were detected:'
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
    opening_line =
      if category == :initializers
        "#{format_initializer_error(key_portions)} #{format_key(key_portions)}"
      else
        format_key(key_portions)
      end
    bad_value = value_of(category, key_portions)
    <<-MESSAGE.strip_heredoc
      #{opening_line}:
      #{format_messages(messages)}
        Value: #{value_of(category, key_portions)}
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

  def format_initializer_error(key_portions)
    key = key_portions.join('.')
    if 'fqdn' == key
      "The FQDN could not be determined. Please set the hostname in #{CONFIG_YML_FILES}"
    elsif %w(data_root git_home git_root symlink_path commits_path).include?(key)
      'Please check the paths keys in the settings -'
    else
      # other possible values: %w(consider_all_requests_local secret_token log_level)
      "Please set a valid value in the #{CONFIG_INITIALIZER_FILES} for"
    end
  end

  def value_of(category, key_portions)
    object = SettingsValidationWrapper.base(category.to_s)
    SettingsValidationWrapper.get_value(object, key_portions)
  end
end
