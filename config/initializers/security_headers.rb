::SecureHeaders::Configuration.default do |config|
  config.hsts                   = 'max_age=99; include_subdomains=true'
  config.x_frame_options        = 'DENY'
  config.x_content_type_options = 'nosniff'
  config.x_xss_protection       = '1; mode=block'
  # By default, load resources only from own origin.
  # For CSS, allow styles from style elements and attributes for GWT.
  config.csp                    = {
    default_src: %w('self'),
    style_src:   %w('self' 'unsafe-inline'),
    script_src: %w('self'),
    frame_src: %w('self'),
    img_src: %w('self'),
    connect_src: %w('self'),
    font_src: %w('self'),
    media_src: %w('self'),
    object_src: %w('self'),
    child_src: %w('self'),
    disable_chrome_extension: true,
  }
end
