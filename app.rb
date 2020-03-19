require './challenge.rb'

def load_db_config
  YAML.safe_load(File.open('config/database.yml'))
end

def init
  db_config = load_db_config
  skip_migration = false
  begin
    ActiveRecord::Base.establish_connection(db_config)
    skip_migration = ActiveRecord::Base.connection.table_exists?('visits')
  rescue ActiveRecord::NoDatabaseError
    database = db_config.delete('database')
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.create_database(database)
    db_config['database'] = database
    ActiveRecord::Base.establish_connection(db_config)
  else
    true
  end

  ActiveRecord::MigrationContext.new('db/migrate/', ActiveRecord::SchemaMigration).migrate unless skip_migration
end

def db_delete(*)
  db_config = load_db_config
  ActiveRecord::Base.establish_connection(db_config)
  ActiveRecord::Base.connection.drop_database(db_config['database'])
  { message: 'Database deleted' }
end

def db_migrate(*)
  init
  ActiveRecord::MigrationContext.new('db/migrate/', ActiveRecord::SchemaMigration).migrate
  { message: 'Database migrated' }
end

def db_create(*)
  db_config = load_db_config
  database = db_config.delete('database')
  ActiveRecord::Base.establish_connection(db_config)
  ActiveRecord::Base.connection.create_database(database)
  { message: 'Database created' }
end

def call(*)
  init
  @challenge = Challenge.new
  data = @challenge.load_data
  visits = @challenge.parse_data(data)
  p @challenge.save_data(visits)
end
