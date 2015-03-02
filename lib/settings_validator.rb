class SettingsValidator
  class SettingsValidator::Error < StandardError
    def initialize(key_chain, message)
      super(message)
      @message = message
      @key_chain = key_chain
    end

    def message
      "Error in #{@key_chain.join('.')}: #{@message}"
    end
  end

  class SettingsValidator::FormatNotEmail < Error; end
  class SettingsValidator::FormatNotURL < Error; end
  class SettingsValidator::KeyNotPresent < Error; end
  class SettingsValidator::KeyNotSet < Error; end
  class SettingsValidator::TypeError < Error; end
  class SettingsValidator::NotAnAbsoluteFilepath < Error; end
  class SettingsValidator::ResourceNotFound < Error; end

  HAS_TO_BE_PRESENT = [
    # settings.yml
    %i(name),
    %i(hostname),
    %i(OMS),
    %i(OMS_qualifier),
    %i(action_mailer delivery_method),
    %i(allow_unconfirmed_access_for_days),
    %i(max_read_filesize),
    %i(max_combined_diff_size),
    %i(ontology_parse_timeout),
    %i(footer),
    %i(exception_notifier enabled),
    %i(exception_notifier email_prefix),
    %i(exception_notifier sender_address),
    %i(exception_notifier exception_recipients),
    %i(workers hets),
    %i(git verify_url),
    %i(git default_branch),
    %i(git push_priority commits),
    %i(git push_priority changed_files_per_commit),
    %i(allowed_iri_schemes),
    %i(display_head_commit),
    %i(display_symbols_tab),
    %i(external_repository_name),
    %i(fallback_commit_user),
    %i(fallback_commit_email),
    %i(format_selection),
    %i(formality_levels),
    %i(license_models),
    %i(ontology_types),
    %i(tasks),

    # hets.yml
    %i(hets_path),
    %i(hets_lib),
    %i(hets_owl_tools),
    %i(version_minimum_version),
    %i(version_minimum_revision),
    %i(stack_size),
    %i(cmd_line_options),
    %i(server_options),
    %i(env LANG),
  ]

  HAS_TO_BE_URL = [
    # settings.yml
    %i(git verify_url),
  ]

  HAS_TO_BE_EMAIL = [
    # settings.yml
    %i(email),
  ]

  HAS_TO_HAVE_TYPE = {
    [Array] => [
      # settings.yml
      %i(footer),
      %i(exception_notifier exception_recipients),
      %i(allowed_iri_schemes),
      %i(formality_levels),
      %i(license_models),
      %i(ontology_types),
      %i(tasks),

      # hets.yml
      %i(hets_path),
      %i(hets_lib),
      %i(hets_owl_tools),
      %i(cmd_line_options),
      %i(server_options),
    ],
    [Fixnum] => [
      # settings.yml
      %i(workers hets),
      %i(git push_priority commits),
      %i(git push_priority changed_files_per_commit),

      # hets.yml
      %i(version_minimum_revision),
    ],
    [Float] => [
      %i(version_minimum_version),
    ],
    [TrueClass, FalseClass] => [
    # settings.yml
      %i(exception_notifier enabled),
      %i(display_head_commit),
      %i(display_symbols_tab),
      %i(format_selection),
    ],
  }

  ARRAY_VALIDATIONS = {
    # settings.yml
    %i(footer) => [:validate_has_keys, :text],
    %i(exception_notifier exception_recipients) => [:validate_has_format_email],
    %i(allowed_iri_schemes) => [:validate_is_present],
    %i(formality_levels) => [:validate_has_keys, :name, :description],
    %i(license_models) => [:validate_has_keys, :name, :url],
    %i(ontology_types) =>
      [:validate_has_keys, :name, :description, :documentation],
    %i(tasks) => [:validate_has_keys, :name, :description],

    # hets.yml
    %i(hets_path) => [:validate_is_absolute_filepath],
    %i(hets_lib) => [:validate_is_absolute_filepath],
    %i(hets_owl_tools) => [:validate_is_absolute_filepath],
    %i(cmd_line_options) => [:validate_is_present],
    %i(server_options) => [:validate_is_present],
  }

  def validate
    @errors = []

    HAS_TO_BE_PRESENT.each { |key_chain| validate_presence(key_chain) }
    HAS_TO_BE_URL.each { |key_chain| validate_format_url(key_chain) }
    HAS_TO_BE_EMAIL.each { |key_chain| validate_format_email(key_chain) }
    HAS_TO_HAVE_TYPE.each do |types, key_chains|
      key_chains.each { |key_chain| validate_type(key_chain, types) }
    end
    validate_arrays

    @errors
  end

  protected

  def validate_arrays
    ARRAY_VALIDATIONS.each do |key_chain, call|
      if array = get_value(key_chain)
        array.each do |value|
          method = call.first
          args = call[1..-1]
          send(method, key_chain, value, *args)
        end
      end
    end
  end

  def get_value(key_chain)
    object = Settings
    key_chain.each do |key|
      object = object[key]
      if object.nil?
        @errors << KeyNotSet.new(key_chain, 'Key not set.')
        return
      end
    end
    object
  end

  def validate_with(key_chain, &block)
    if value = get_value(key_chain)
      block.call(value)
    end
  end

  def validate_directory_exists(key_chain)
    path = get_value(cfg_key_chain)
    unless File.directory?(path)
      @errors << NotADirectory.new(cfg_key_chain,
        "Path is not a directory: #{path}")
    end
  end

  def validate_presence(key_chain)
    validate_with(key_chain) do |value|
      validate_is_present(key_chain, value)
    end
  end

  def validate_type(key_chain, types)
    validate_with(key_chain) do |value|
      unless types.any? { |type| value.is_a?(type) }
        @errors << TypeError.new(key_chain,
          ["Value should have as type one of #{types.join(', ')}, ",
           "but has type #{value.class}."].join)
      end
    end
  end

  def validate_format_url(key_chain)
    validate_with(key_chain) do |value|
      unless value.match(URI.regexp)
        @errors << FormatNotURL(key_chain, "Value is not a URL: #{value}")
      end
    end
  end

  def validate_format_email(key_chain)
    validate_with(key_chain) do |value|
      validate_has_format_email(key_chain, value)
    end
  end

  def validate_has_keys(key_chain, value, *keys)
    unless value.present? && keys.all? { |key| value[key].present? }
      @errors << KeyNotSet.new(key_chain,
        "Value needs to have keys: #{keys.join(', ')}")
    end
  end

  def validate_has_format_email(key_chain, value)
    unless value.present? && value.match(/@/)
      @errors << FormatNotEmail(key_chain,
        "Value is not an email address: #{value}")
    end
  end

  def validate_is_present(key_chain, value)
    unless value.present?
      @errors << KeyNotPresent.new(key_chain, 'Value not present.')
    end
  end

  def validate_is_absolute_filepath(key_chain, value)
    unless value.present? && %w(/ ~/).any? { |start| value.start_with?(start) }
      @errors << NotAnAbsoluteFilepath.new(key_chain,
        'Has to be an absolute filepath.')
    end
  end
end
