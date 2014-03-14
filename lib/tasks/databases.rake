require 'extend/active_record/connection_adapters/postgre_sql_adapter'

namespace :db do

  desc "Drop all tables in the database"
  task :drop_tables => ["db:truncate", "db:load_config"] do
    begin
      config = ActiveRecord::Base.configurations[::Rails.env]
      ActiveRecord::Base.establish_connection
      case config["adapter"]
      when "mysql", "postgresql"
        ActiveRecord::Base.connection.tables.each do |table|
          ActiveRecord::Base.connection.execute("DROP TABLE #{table} CASCADE")
        end
      end
    end
  end

  desc "Drop all types self-defined in the database"
  task :drop_types => ["db:truncate", "db:load_config"] do
    begin
      config = ActiveRecord::Base.configurations[::Rails.env]
      ActiveRecord::Base.establish_connection
      case config["adapter"]
      when "postgresql"
        ActiveRecord::Base.connection.types.each do |pgsql_type|
          ActiveRecord::Base.connection.execute("DROP TYPE #{pgsql_type} CASCADE")

        end
      end
    end
  end

  task :truncate => ["db:load_config", "environment"] do
    DatabaseCleaner.clean_with :truncation
  end

  namespace :migrate do
    desc 'Perform migration but not before cleaning the db'
    task :clean do
      Rake::Task["db:drop_tables"].invoke
      Rake::Task["db:drop_types"].invoke
      Rake::Task["db:migrate"].invoke
    end
  end
end
