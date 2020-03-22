require 'simplecov'
require 'rspec/simplecov'
require 'webmock/rspec'
require 'support/fake_api'

SimpleCov.minimum_coverage 100
SimpleCov.start

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')
require 'challenge'

SAMPLE_RESPONSE_FILE = File.join(File.dirname(__FILE__), "support", "api_response.json")
DB_CONFIG_FILE = File.join(File.dirname(__FILE__), "..", "config", "database_test.yml")

class Array
  def sorted_by?(key)
    reduce do |l, r|
      return false if l[key] > r[key]

      l
    end
    return true
  end
end
