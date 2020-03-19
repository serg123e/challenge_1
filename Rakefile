# frozen_string_literal: true

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

namespace :aws do
  desc 'zip'
  task :zip do
    system('zip -r function.zip spec models db config vendor/* lib/* app.rb challenge.rb')
  end

  desc 'Deploy function to AWS'
  task :deploy do    
    require 'aws-sdk-lambda'  # v2: require 'aws-sdk'

    client = Aws::Lambda::Client.new(region: 'eu-central-1')

    args = {}
    args[:role] = 'arn:aws:iam::935901954397:role/LambdaRDS'
    args[:function_name] = 'shastic-lambda'
    args[:handler] = 'app.handler'

    # Also accepts nodejs, nodejs4.3, and python2.7
    args[:runtime] = 'ruby2.5'

    code = {}
#    code[:zip_file] = 'deploy2.zip'
    code[:zip_file] = File.open('function.zip','rb').read
#    code[:s3_bucket] = 'shastic-s3'
#    code[:s3_key] = 'deploy2.zip'

    args[:code] = code

    client.update_function(args)    
    puts 'Function created.'
    
  end


  desc 'Invoke function to AWS'
  task :invoke do    
    require 'aws-sdk-lambda'
    client = Aws::Lambda::Client.new(region: 'eu-central-1')

    resp = client.invoke({
                         function_name: 'shastic-lambda',
                         invocation_type: 'RequestResponse',
                         log_type: 'None',
                         payload: ''
                       })

    p resp
    puts resp.payload.string
    
  end



end
begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  # no rspec available
end
