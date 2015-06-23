class SettingsValidationWrapper
  include ActiveModel::Validations
  include SettingsValidationWrapper::Validators

  # We assume that deployment is done on a linux machine that has 'nproc'.
  # Counting processors is different on other machines. For them, we would need
  # to use a gem.
  NPROC_PATH = `which nproc`
  NPROC_AVAILABLE = NPROC_PATH.present? && File.executable?(NPROC_PATH)

  PRESENCE = %i(yml__name
                yml__OMS
                yml__OMS_qualifier
                yml__action_mailer__delivery_method
                yml__action_mailer__smtp_settings__address
                yml__allow_unconfirmed_access_for_days
                yml__max_read_filesize
                yml__max_combined_diff_size
                yml__ontology_parse_timeout
                yml__footer
                yml__exception_notifier__email_prefix
                yml__exception_notifier__sender_address
                yml__exception_notifier__exception_recipients
                yml__paths__data
                yml__paths__git_repositories
                yml__paths__symlinks
                yml__paths__commits
                yml__git__verify_url
                yml__git__default_branch
                yml__git__push_priority__commits
                yml__git__push_priority__changed_files_per_commit
                yml__git__fallbacks__committer_name
                yml__git__fallbacks__committer_email
                yml__allowed_iri_schemes
                yml__external_repository_name
                yml__formality_levels
                yml__license_models
                yml__ontology_types
                yml__tasks

                yml__hets__version_minimum_version
                yml__hets__version_minimum_revision
                yml__hets__stack_size
                yml__hets__cmd_line_options
                yml__hets__server_options
                yml__hets__env__LANG

                initializers__fqdn
                initializers__data_root
                initializers__git_home
                initializers__git_root
                initializers__symlink_path
                initializers__commits_path)

  PRESENCE_IN_PRODUCTION = %i(yml__hets__executable_path
                              yml__hets__instances_count)

  BOOLEAN = %i(yml__exception_notifier__enabled
               yml__display_head_commit
               yml__display_symbols_tab
               yml__format_selection
               yml__action_mailer__perform_deliveries
               yml__action_mailer__raise_delivery_errors
               yml__action_mailer__smtp_settings__enable_starttls_auto

               initializers__consider_all_requests_local)

  FIXNUM = %i(yml__hets__instances_count
              yml__action_mailer__smtp_settings__port
              yml__allow_unconfirmed_access_for_days
              yml__git__push_priority__commits
              yml__git__push_priority__changed_files_per_commit
              yml__access_token__expiration_minutes
              yml__hets__time_between_updates
              yml__hets__version_minimum_revision)

  FLOAT = %i(yml__hets__version_minimum_version)

  STRING = %i(yml__name
              yml__OMS
              yml__OMS_qualifier
              yml__email
              yml__action_mailer__smtp_settings__address
              yml__exception_notifier__email_prefix
              yml__exception_notifier__sender_address
              yml__paths__data
              yml__paths__git_repositories
              yml__paths__symlinks
              yml__paths__commits
              yml__git__verify_url
              yml__git__default_branch
              yml__git__fallbacks__committer_name
              yml__git__fallbacks__committer_email
              yml__external_repository_name)

  ARRAY = %i(yml__footer
             yml__exception_notifier__exception_recipients
             yml__allowed_iri_schemes
             yml__formality_levels
             yml__license_models
             yml__ontology_types
             yml__tasks

             yml__hets__cmd_line_options
             yml__hets__server_options)

  DIRECTORY_PRODUCTION = %i(initializers__data_root
                            initializers__git_home
                            initializers__git_root
                            initializers__symlink_path
                            initializers__commits_path)

  ELEMENT_PRESENT = %i(yml__allowed_iri_schemes
                       yml__hets__cmd_line_options
                       yml__hets__server_options)


  validates_presence_of *PRESENCE
  validates_presence_of *PRESENCE_IN_PRODUCTION, if: :in_production?

  BOOLEAN.each do |field|
    validates field, class: {in: [TrueClass, FalseClass]}
  end
  FIXNUM.each { |field| validates field, class: {in: [Fixnum]} }
  FLOAT.each { |field| validates field, class: {in: [Float]} }
  STRING.each { |field| validates field, class: {in: [String]} }
  ARRAY.each { |field| validates field, class: {in: [Array]} }
  DIRECTORY_PRODUCTION.each do |field|
    validates field, directory: true, if: :in_production?
  end
  ELEMENT_PRESENT.each { |field| validates field, elements_are_present: true }

  validates :initializers__secret_token,
            presence: true,
            length: {minimum: 64},
            if: :in_production?

  validates :yml__email,
            email_from_host: {hostname: ->(record) { record.initializers__fqdn }},
            if: :in_production?

  validates :yml__exception_notifier__exception_recipients,
            elements_are_email: true

  validates :yml__action_mailer__delivery_method,
            inclusion: {in: %i(sendmail smtp file test)}

  validates :yml__allow_unconfirmed_access_for_days,
            numericality: {greater_than_or_equal_to: 0}

  validates :yml__max_read_filesize, numericality: {greater_than: 1024}
  validates :yml__max_combined_diff_size, numericality: {greater_than: 2048}
  validates :yml__ontology_parse_timeout, numericality: {greater_than: 0}
  validates :yml__git__verify_url, format: URI.regexp
  validates :yml__git__push_priority__commits,
            numericality: {greater_than_or_equal_to: 1}
  validates :yml__git__push_priority__changed_files_per_commit,
            numericality: {greater_than_or_equal_to: 1}
  validates :yml__access_token__expiration_minutes,
            numericality: {greater_than_or_equal_to: 1}

  validates :yml__footer, elements_have_keys: {keys: %i(text)}
  validates :yml__formality_levels,
            elements_have_keys: {keys: %i(name description)}
  validates :yml__license_models, elements_have_keys: {keys: %i(name url)}
  validates :yml__ontology_types,
            elements_have_keys: {keys: %i(name description documentation)}
  validates :yml__tasks,
            elements_have_keys: {keys: %i(name description)}

  validates :initializers__log_level,
            inclusion: {in: %i(fatal error warn info debug)}

  validates :yml__hets__executable_path, executable: true, if: :in_production?
  if NPROC_AVAILABLE
    validates :yml__hets__instances_count,
              numericality: {greater_than: 0,
                             less_than_or_equal_to: `nproc`.to_i},
              if: :in_production?
  else
    validates :yml__hets__instances_count,
              numericality: {greater_than: 0},
              if: :in_production?
  end

  validates :yml__hets__time_between_updates,
            numericality: {greater_than_or_equal_to: 1}

  protected

  def in_production?
    Rails.env.production?
  end

  # We use '__' as a separator. It will be replaced by a dot.
  # This uses the fact that our settings-keys never have two consecutive
  # underscores.
  # yml__git__verify_url maps to Settings.git.verify_url.
  # initializers__git__verify_url maps to @config.git.verify_url.
  def method_missing(method_name, *_args)
    portions = method_name.to_s.split('__')
    object = base(portions[0])
    key_chain = portions[1..-1]
    if object == :error || key_chain.blank?
      raise NoMethodError,
        "undefined method `#{method_name}' for #{self}:#{self.class}"
    end
    get_value(object, key_chain)
  end

  def base(first_portion)
    case first_portion
    when 'yml'
      Settings
    when 'initializers'
      Ontohub::Application.config
    else
      :error
    end
  end

  def get_value(object, key_chain)
    key_chain.each do |key|
      if object.respond_to?(key)
        object = object.send(key)
      else
        # The nil value shall be caught by the presence validators.
        return nil
      end
    end
    object
  end
end
