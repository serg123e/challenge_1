# frozen_string_literal: true
require './challenge.rb'

def init
    db_config = YAML.safe_load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::MigrationContext.new('db/migrate/', ActiveRecord::SchemaMigration).migrate
end

def handler(event:, context:)
  call
end

def call
  init
  @challenge = Challenge.new
  data = @challenge.load_data('')
  visits = @challenge.parse_data( data )
  @challenge.save_data( visits )
end       
