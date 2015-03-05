class SettingsValidationWrapper
  include ActiveModel::Validations
  include SettingsValidationWrapper::Validators

  PRESENCE = %i(yml__name
                yml__hostname
                yml__OMS
                yml__OMS_qualifier
                yml__action_mailer__delivery_method
                yml__allow_unconfirmed_access_for_days
                yml__max_read_filesize
                yml__max_combined_diff_size
                yml__ontology_parse_timeout
                yml__footer
                yml__exception_notifier__email_prefix
                yml__exception_notifier__sender_address
                yml__exception_notifier__exception_recipients
                yml__workers__hets
                yml__git__verify_url
                yml__git__default_branch
                yml__git__push_priority__commits
                yml__git__push_priority__changed_files_per_commit
                yml__allowed_iri_schemes
                yml__external_repository_name
                yml__fallback_commit_user
                yml__fallback_commit_email
                yml__formality_levels
                yml__license_models
                yml__ontology_types
                yml__tasks

                yml__hets_path
                yml__hets_lib
                yml__hets_owl_tools
                yml__version_minimum_version
                yml__version_minimum_revision
                yml__stack_size
                yml__cmd_line_options
                yml__server_options
                yml__env__LANG

                initializers__data_root
                initializers__git_home
                initializers__git_root
                initializers__symlink_path
                initializers__commits_path)

  BOOLEAN = %i(yml__exception_notifier__enabled
               yml__display_head_commit
               yml__display_symbols_tab
               yml__format_selection)

  FIXNUM = %i(yml__workers__hets
              yml__git__push_priority__commits
              yml__git__push_priority__changed_files_per_commit
              yml__version_minimum_revision)

  FLOAT = %i(yml__version_minimum_version)

  ARRAY = %i(yml__footer
             yml__exception_notifier__exception_recipients
             yml__allowed_iri_schemes
             yml__formality_levels
             yml__license_models
             yml__ontology_types
             yml__tasks

             yml__hets_path
             yml__hets_lib
             yml__hets_owl_tools
             yml__cmd_line_options
             yml__server_options)

  DIRECTORY_PRODUCTION = %i(initializers__data_root
                            initializers__git_home
                            initializers__git_root
                            initializers__symlink_path
                            initializers__commits_path)

  ABSOLUTE_FILEPATH = %i(yml__hets_path
                         yml__hets_lib
                         yml__hets_owl_tools)

  ELEMENT_PRESENT = %i(yml__allowed_iri_schemes
                       yml__cmd_line_options
                       yml__server_options)


  validates_presence_of *PRESENCE
  validates_presence_of :initializers__secret_token, if: :in_production?

  validates :yml__git__verify_url, format: URI.regexp
  validates :yml__email, email: true

  # We assume that deployment is done on a linux machine that has 'nproc'.
  # Counting processors is different on other machines.
  if `which nproc`.present? && File.executable?(`which nproc`)
    validates :yml__workers__hets,
              numericality: {greater_than: 0,
                             less_than_or_equal_to: `nproc`.to_i}
  else
    validates :yml__workers__hets, numericality: {greater_than: 0}
  end

  validates :yml__footer, elements_have_keys: {keys: %i(text)}
  validates :yml__formality_levels,
            elements_have_keys: {keys: %i(name description)}
  validates :yml__license_models, elements_have_keys: {keys: %i(name url)}
  validates :yml__ontology_types,
            elements_have_keys: {keys: %i(name description documentation)}
  validates :yml__tasks,
            elements_have_keys: {keys: %i(name description)}

  validates :yml__hets_path, elements_one_executable: true

  BOOLEAN.each do |field|
    validates field, class: {in: [TrueClass, FalseClass]}
  end
  FIXNUM.each { |field| validates field, class: {in: [Fixnum]} }
  FLOAT.each { |field| validates field, class: {in: [Float]} }
  DIRECTORY_PRODUCTION.each do |field|
    validates field, directory: true, if: :in_production?
  end

  ARRAY.each { |field| validates field, class: {in: [Array]} }
  ABSOLUTE_FILEPATH.each do |field|
    validates field, elements_are_absolute_filepaths: true
  end
  ELEMENT_PRESENT.each { |field| validates field, elements_are_present: true }
  validates :yml__exception_notifier__exception_recipients,
            elements_are_email: true

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
