require 'active_record'
namespace :db do
  db_config = YAML.safe_load(File.open('config/database.yml'))

  desc 'Create the database'
  task :create do
    database = db_config.delete('database')
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.create_database(database)
    puts 'Database created.'
  end

  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::MigrationContext.new('db/migrate/', ActiveRecord::SchemaMigration).migrate
    puts 'Database migrated.'
  end

  desc 'Drop the database'
  task :drop do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.drop_database(db_config['database'])
    puts 'Database deleted.'
  end
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  puts "no rspec available"
end
