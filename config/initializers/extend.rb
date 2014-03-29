Dir['lib/extend/**/*.rb'].each { |f| require_relative Rails.root.join(f) }
