class SettingsValidator
  class SettingsValidator::ValidationError < ::StandardError; end

  class SettingsValidator::Error < ::StandardError
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
  class SettingsValidator::NotADirectory < Error; end
  class SettingsValidator::NotAnAbsoluteFilepath < Error; end
  class SettingsValidator::ResourceNotFound < Error; end
  class SettingsValidator::TypeError < Error; end

  HAS_TO_BE_PRESENT = [
    # settings.yml
    %i(yml name),
    %i(yml hostname),
    %i(yml OMS),
    %i(yml OMS_qualifier),
    %i(yml action_mailer delivery_method),
    %i(yml allow_unconfirmed_access_for_days),
    %i(yml max_read_filesize),
    %i(yml max_combined_diff_size),
    %i(yml ontology_parse_timeout),
    %i(yml footer),
    %i(yml exception_notifier enabled),
    %i(yml exception_notifier email_prefix),
    %i(yml exception_notifier sender_address),
    %i(yml exception_notifier exception_recipients),
    %i(yml workers hets),
    %i(yml git verify_url),
    %i(yml git default_branch),
    %i(yml git push_priority commits),
    %i(yml git push_priority changed_files_per_commit),
    %i(yml allowed_iri_schemes),
    %i(yml display_head_commit),
    %i(yml display_symbols_tab),
    %i(yml external_repository_name),
    %i(yml fallback_commit_user),
    %i(yml fallback_commit_email),
    %i(yml format_selection),
    %i(yml formality_levels),
    %i(yml license_models),
    %i(yml ontology_types),
    %i(yml tasks),

    # hets.yml
    %i(yml hets_path),
    %i(yml hets_lib),
    %i(yml hets_owl_tools),
    %i(yml version_minimum_version),
    %i(yml version_minimum_revision),
    %i(yml stack_size),
    %i(yml cmd_line_options),
    %i(yml server_options),
    %i(yml env LANG),

    # paths.rb
    %i(initializers data_root),
    %i(initializers git_home),
    %i(initializers git_root),
    %i(initializers symlink_path),
    %i(initializers commits_path),
  ]

  HAS_TO_BE_PRESENT_IN_PRODUCTION = [
    %i(initializers secret_token),
  ]

  HAS_TO_BE_DIRECTORY_IN_PRODUCTION = [
    # paths.rb
    %i(initializers data_root),
    %i(initializers git_home),
    %i(initializers git_root),
    %i(initializers symlink_path),
    %i(initializers commits_path),
  ]

  HAS_TO_BE_URL = [
    # settings.yml
    %i(yml git verify_url),
  ]

  HAS_TO_BE_EMAIL = [
    # settings.yml
    %i(yml email),
  ]

  HAS_TO_HAVE_TYPE = {
    [Array] => [
      # settings.yml
      %i(yml footer),
      %i(yml exception_notifier exception_recipients),
      %i(yml allowed_iri_schemes),
      %i(yml formality_levels),
      %i(yml license_models),
      %i(yml ontology_types),
      %i(yml tasks),

      # hets.yml
      %i(yml hets_path),
      %i(yml hets_lib),
      %i(yml hets_owl_tools),
      %i(yml cmd_line_options),
      %i(yml server_options),
    ],
    [Fixnum] => [
      # settings.yml
      %i(yml workers hets),
      %i(yml git push_priority commits),
      %i(yml git push_priority changed_files_per_commit),

      # hets.yml
      %i(yml version_minimum_revision),
    ],
    [Float] => [
      %i(yml version_minimum_version),
    ],
    [TrueClass, FalseClass] => [
    # settings.yml
      %i(yml exception_notifier enabled),
      %i(yml display_head_commit),
      %i(yml display_symbols_tab),
      %i(yml format_selection),
    ],
  }

  ARRAY_VALIDATIONS = {
    # settings.yml
    %i(yml footer) => [:validate_value_has_keys, :text],
    %i(yml exception_notifier exception_recipients) =>
      [:validate_value_has_format_email],
    %i(yml allowed_iri_schemes) => [:validate_value_is_present],
    %i(yml formality_levels) => [:validate_value_has_keys, :name, :description],
    %i(yml license_models) => [:validate_value_has_keys, :name, :url],
    %i(yml ontology_types) =>
      [:validate_value_has_keys, :name, :description, :documentation],
    %i(yml tasks) => [:validate_value_has_keys, :name, :description],

    # hets.yml
    %i(yml hets_path) => [:validate_value_is_absolute_filepath],
    %i(yml hets_lib) => [:validate_value_is_absolute_filepath],
    %i(yml hets_owl_tools) => [:validate_value_is_absolute_filepath],
    %i(yml cmd_line_options) => [:validate_value_is_present],
    %i(yml server_options) => [:validate_value_is_present],
  }

  attr_reader :errors

  def initialize(config)
    @config = config
  end

  def validate
    @errors = []

    HAS_TO_BE_PRESENT.each { |key_chain| validate_presence(key_chain) }
    HAS_TO_BE_URL.each { |key_chain| validate_format_url(key_chain) }
    HAS_TO_BE_EMAIL.each { |key_chain| validate_format_email(key_chain) }
    HAS_TO_HAVE_TYPE.each do |types, key_chains|
      key_chains.each { |key_chain| validate_type(key_chain, types) }
    end

    if Rails.env.production?
      HAS_TO_BE_DIRECTORY_IN_PRODUCTION.each do |key_chain|
        validate_directory_exists(key_chain)
      end
      HAS_TO_BE_PRESENT_IN_PRODUCTION.each do |key_chain|
        validate_presence(key_chain)
      end
    end

    validate_arrays
    validate_specials

    if @errors.present?
      raise ValidationError.new(@errors.map(&:message).join("\n"))
    end
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

  def validate_specials
    validate_hets_path
  end

  def validate_hets_path
    key_chain = %i(yml hets_path)
    hets_paths = get_value(key_chain)
    unless hets_paths.any? { |path| File.executable?(path) }
      @errors << ResourceNotFound.new(key_chain,
        "Executable 'hets' not found in any of the given paths: #{hets_paths}")
    end
  end

  def get_value(key_chain)
    object = base(key_chain.first)
    key_chain[1..-1].each do |key|
      object = object.send(key)
      if object.nil?
        @errors << KeyNotSet.new(key_chain, 'Key not set.')
        return
      end
    end
    object
  end

  def base(namespace)
    if namespace == :yml
      Settings
    else
      @config
    end
  end

  def validate_with(key_chain, &block)
    if value = get_value(key_chain)
      block.call(value)
    end
  end

  def validate_directory_exists(key_chain)
    path = get_value(key_chain)
    unless File.directory?(path)
      @errors << NotADirectory.new(key_chain,
        "Path is not a directory: #{path}")
    end
  end

  def validate_presence(key_chain)
    validate_with(key_chain) do |value|
      validate_value_is_present(key_chain, value)
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
      validate_value_has_format_email(key_chain, value)
    end
  end

  def validate_value_has_keys(key_chain, value, *keys)
    unless value.present? && keys.all? { |key| value[key].present? }
      @errors << KeyNotSet.new(key_chain,
        "Value needs to have keys: #{keys.join(', ')}")
    end
  end

  def validate_value_has_format_email(key_chain, value)
    unless value.present? && value.match(/@/)
      @errors << FormatNotEmail(key_chain,
        "Value is not an email address: #{value}")
    end
  end

  def validate_value_is_present(key_chain, value)
    unless value.present?
      @errors << KeyNotPresent.new(key_chain, 'Value not present.')
    end
  end

  def validate_value_is_absolute_filepath(key_chain, value)
    unless value.present? && %w(/ ~/).any? { |start| value.start_with?(start) }
      @errors << NotAnAbsoluteFilepath.new(key_chain,
        'Has to be an absolute filepath.')
    end
  end
end
