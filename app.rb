require './challenge.rb'

SAMPLE_RESPONSE_FILE = File.join(File.dirname(__FILE__), "spec", "support", "api_response.json")
DB_CONFIG_FILE = File.join(File.dirname(__FILE__), "config", "database.yml")

def call
  p Challenge.new.run
end
