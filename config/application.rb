require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'elasticsearch/rails/instrumentation'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Ontohub
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # HACK https://gist.github.com/1184816
    if defined? Compass
      config.sass.load_paths << Compass::Frameworks['blueprint'].stylesheets_directory
      config.sass.load_paths << Compass::Frameworks['compass'].stylesheets_directory
    end

    # Mailer Layout for Devise https://github.com/plataformatec/devise/issues/1671
    config.to_prepare { Devise::Mailer.layout "mailer" }

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.i18n.enforce_available_locales = true

    # Including Jstree Themes Styles in Precompiling
    config.assets.precompile += %w(jstree-themes/**/*)

    # Include the external mappings
    f = File.join(Rails.root, 'config', 'external_link_mapping.yml')
    config.external_url_mapping = APP_CONFIG = YAML.load(File.read(f))


    # Check Settings and replace invalid/add required values using
    # reasonable defaults when needed.
    tmp = Settings.hostname ? Settings.hostname.to_s : ''
    i = tmp.index(':')
    if i
      port = tmp[i..-1]			# yes, we take the ':'
      tmp = tmp[0..i-1]
    else
      port = ''
    end
    begin
      if tmp.length < 1
        if Rails.env == 'production'
          tmp = Socket.gethostname
          port = Rails.env != 'production' ? ':3000' : ''
        else
          tmp = 'localhost'
          port = ':3000'
        end
      end
    rescue
      tmp = nil
    end
    if tmp && tmp != 'localhost' && ! tmp.index('.')	# need fqdn?
      begin
        tmp = Addrinfo.tcp(tmp, 0).getnameinfo.first
      rescue
        tmp = nil
      end
    end
    if ! tmp
      raise 'Unable to determine the FQDN of this machine. Please add an ' \
        'appropriate "hostname: your_fqdn" to the config/settings.local.yml ' \
        'file and try again.'
    end
    Settings.hostname = tmp + port
    config.fqdn = tmp
    config.port = port[1..-1]

    if Settings.log_level
      tmp = Settings.log_level.to_s
      if tmp.in? ['fatal', 'error', 'warn', 'info', 'debug']
        config.log_level = tmp.intern
      else
        STDERR.puts "Invalid setting log_level '#{tmp}' ignored"
      end
    end

    tmp = Settings.consider_all_requests_local
    config.consider_all_requests_local = tmp && tmp.to_s == 'true'

    # If one has configured it, make sure that at least all recipients are ok
    ex = Settings.exception_notifier
    if ex
      tmp = ex.exception_recipient
      if tmp
        tmp = Array(tmp.to_s) unless tmp.is_a?(Array)
      else
        tmp = []
      end
      rs = []
      tmp.each do |r|
        r = r.to_s
        rs.push(r) if (r && r.length > 0)
      end
      ex.exception_recipient = rs
      ex.enabled = rs.size > 0
      ex.mail_prefix = ex.mail_prefix.to_s if ex.mail_prefix
      ex.sender_address = ex.sender_address.to_s if ex.sender_address
    end

    tmp = Settings.secret_token ? Settings.secret_token.to_s : ''
    # the internet whistles at least 30 characters, we want more
    if tmp.length >= 64
      config.secret_token = tmp
      # Need to keep it consistent - otherwise when the initializer
      # 'secret_token.rb' gets run, it may override this token and thus all
      # initializers running after it may use a different token. So ignore any
      # changes during the initializer phase and restore behavior when finished.
      def config.secret_token=(value)
      end
      config.after_initialize do
        def config.secret_token=(value)
          @secret_token = value.to_s
        end
      end
    else
      f = File.join(Rails.root, 'config', 'initializers', 'secret_token.rb')
      if File.exist?(f)
        # for backward compatibility. Because the devise initializer uses this
        # key as well and gets invoked before secret_token.rb, we pull it in
        # here and do not need to scratch our head about init orders ...
        require f
      end
      if ! (config.secret_token && config.secret_token.to_s.length > 64)
        # We raise an error here to avoid that devise emits a misleading
        # message wrt. the missing token.
        raise 'No secret token found. You should generate a secret token and ' \
          'add it to the config/settings.local.yml (secret_token: your_token).'\
          ' To generate one, the following command can be used: ' \
          '"openssl rand -hex -rand /var/log/messages 64 2>/dev/null".'
      end
    end

    Settings.email = "noreply@#{config.fqdn}" unless Settings.email
    config.email = Settings.email

    # init Devise.mailer.*
    s = Settings.action_mailer
    ex = config.action_mailer
    ex.default_url_options = { :host => config.fqdn, :port => config.port }
    if ! s
      ex.perform_deliveries = Rails.env != 'test'
      ex.raise_delivery_errors = Rails.env != 'production'
    else
      ex.perform_deliveries = s.perform_deliveries \
        ? s.perform_deliveries.to_s == 'true'
        : Rails.env != 'test'
      ex.raise_delivery_errors = s.raise_delivery_errors \
        ? s.raise_delivery_errors.to_s == 'true'
        : Rails.env != 'production'
    end
    if ! (s && s.smtp_settings)
      ex.smtp_settings = {
        # the Devise.mailer defaults do NOT make sense
        :address => 'mail',
        :port => 25,
        :domain => nil,
        :enable_starttls_auto => true,
        :password => nil,
        :authentication => nil,
      }
    else
      s = s.smtp_settings
      tmp = s.address ? s.address.to_s : ''
      ex.address = tmp.length > 0 ? tmp : 'mail'
      i = s.port ? s.port.to_i : 0
      ex.port = i > 0 ? i : 25
      tmp = s.domain ? s.domain.to_s : ''
      ex.domain = tmp.length > 0 ? tmp : nil
      tmp = s.enable_starttls_auto ? s.enable_starttls_auto.to_s : ''
      ex.enable_starttls_auto = tmp == 'true'
      ex.password = s.password.to_s if s.password
      ex.authentication = s.authentication.to_s if s.authentication
    end
    tmp = (s && s.delivery_method) ? s.delivery_method.to_s : ''
    ex.delivery_method = (tmp.in? ['sendmail', 'smtp', 'file', 'test']) \
      ? tmp.intern
      : 'sendmail'.intern

    tmp = Settings.name ? Settings.name : ''
    config.name = tmp.length < 1 ? 'MyOntohub' : tmp
	Settings.name = config.name

    tmp = Settings.asset_host ? Settings.asset_host.to_s : ''
    config.action_controller.asset_host = tmp if tmp.length > 0

    config.display_head_commit = Settings.display_head_commit \
      ? Settings.display_head_commit.to_s == 'true'
      : Rails.env != 'production'
    Settings.display_head_commit = config.display_head_commit

	Settings.display_symbols_tab =
      Settings.display_symbols_tab && Settings.display_symbols_tab.to_s=='true'

    Settings.format_selection =
      Settings.format_selection && Settings.format_selection.to_s == 'true'

    if ! Settings.footer
      # only if nil!
      Settings.footer = [
        OpenStruct.new('text'=>'Imprint', 'href'=>'http://about.ontohub.org/'),
        OpenStruct.new('text'=>'Source Code',
          'href'=>'https://github.com/ontohub/ontohub')
      ]
    end

    i = Settings.access_token && Settings.access_token.expiration_minutes \
      ? Settings.access_token.expiration_minutes.to_i
      : 0
    Settings.access_token = i > 0 ? i : 360

    # for devise config, only
    i = Settings.allow_unconfirmed_access_for_days \
      ? Settings.allow_unconfirmed_access_for_days.to_i
      : -1
    Settings.allow_unconfirmed_access_for_days = i < 0 ? 3 : i

	# deprecated keys
    rs = Settings.fallback_commit_email \
      ? Settings.fallback_commit_email.to_s
      : 'websvc'
    r = Settings.fallback_commit_user \
      ? Settings.fallback_commit_user
      : "websvc@#{config.fqdn}"
    s = Settings.external_repository_name \
      ? Settings.external_repository_name.to_s
      : 'External'

    if ! Settings.git
      Settings.git = OpenStruct.new('data_dir'=>'/data/git',
        'verify_url'=>Settings.hostname, 'default_branch'=>'master',
        'push_priority'=>
          OpenStruct.new('commits'=>1, 'changed_files_per_commit'=>5),
        'fallbacks'=>OpenStruct.new('user'=>rs, 'email'=>r, 'repo_name'=>s)
      )
    else
      ex = Settings.git
      ex.data_dir = '/data/git' unless ex.data_dir
      ex.verify_url = 'http://' + Settings.hostname + '/' unless ex.verify_url
      ex.default_branch = 'master' unless ex.default_branch
      if ! ex.push_priority
        ex.push_priority =
          OpenStruct.new('commits'=>1, 'changed_files_per_commit'=>5)
      else
        ex.push_priority.commits = 1 \
          unless ex.push_priority.commits && ex.push_priority.commits.to_i > 0
        ex.push_priority.changed_files_per_commit = 1 \
          unless ex.push_priority.changed_files_per_commit \
            && ex.push_priority.changed_files_per_commit.to_i > 0
      end
      if ! ex.fallbacks
        ex.fallbacks = OpenStruct.new('user'=>rs, 'email'=>r, 'repo_name'=>s)
      else
        tmp = (ex.fallbacks.user && ex.fallbacks.user) \
          ? ex.fallbacks.user.to_s
          : ''
        ex.fallbacks.user = tmp.length > 0 ? tmp : rs
        tmp = (ex.fallbacks.email && ex.fallbacks.email) \
          ? ex.fallbacks.email.to_s
          : ''
        ex.fallbacks.email = tmp.length > 0 ? tmp : r
        tmp = (ex.fallbacks.repo_name && ex.fallbacks.repo_name) \
          ? ex.fallbacks.repo_name.to_s
          : ''
        ex.fallbacks.repo_name = tmp.length > 0 ? tmp : r
      end
    end

    if ! Settings.workers
      Settings.workers = OpenStruct.new('hets' => 4)
    elsif ! (Settings.workers.hets && Settings.workers.hets.to_i > 1)
      Settings.workers.hets = 4
    end

    Settings.ontology_parse_timeout = Settings.ontology_parse_timeout \
      ? Settings.ontology_parse_timeout.to_i
      : 6

    i = Settings.max_read_filesize ? Settings.max_read_filesize.to_i : 0
    Settings.max_read_filesize = i < 1024 ? 524_288 : i

    i=Settings.max_combined_diff_size ? Settings.max_combined_diff_size_to_i : 0
    Settings.max_read_filesize = i < 2048 ? 1_048_576 : i

  end
end
