::SecureHeaders::Configuration.configure do |config|
  config.hsts                   = {:max_age => 99, :include_subdomains => true}
  config.x_frame_options        = 'DENY'
  config.x_content_type_options = "nosniff"
  config.x_xss_protection       = {:value => 1, :mode => false}
  # By default, load resources only from own origin.
  # For CSS, allow styles from style elements and attributes for GWT.
  config.csp                    = {
    default_src: "self",
    style_src:   "'self' 'unsafe-inline'",
    disable_chrome_extension: true,
  }
end
