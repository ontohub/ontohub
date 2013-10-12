# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

ActiveRecord::Base.logger = Logger.new($stdout)

# Run background jobs inline
require 'sidekiq/testing'
Sidekiq::Testing.inline!

# Include every .rb file inside db/seeds directory.
Dir["#{Rails.root}/db/seeds/*.rb"].sort.each do |path|
  puts File.basename path
  require path
end

