require_relative 'challenge_data_loader.rb'
require_relative 'challenge_data_parser.rb'
require_relative 'challenge_data_saver.rb'
require "json"
require "net/http"
require "yaml"
require "active_record"
require "./models/visit"
require "./models/pageview"

# PORO that loads data from API and saves to MySQL
class Challenge
  def run
    data_collection = ChallengeDataLoader.new.load_data
    saver = ChallengeDataSaver.new
    parser = ChallengeDataParser.new

    parser.parse_data(data_collection).each do |visit|
      saver.save_row(visit)
    end

    return { created: { visits: saver.visits_count,
                        pageviews: saver.pageviews_count },
             parsing_errors: parser.errors }
  end
end
