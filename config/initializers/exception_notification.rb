config = Settings.exception_notifier

if config.try(:enabled)

  require 'exception_notification/rails'
  require 'exception_notification/sidekiq'

  ExceptionNotification.configure do |config|
    # Ignore additional exception types.
    # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
    # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

    # Email notifier sends notifications by email.
    config.add_notifier :email, config.to_hash

  end

end