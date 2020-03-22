# Base FetchStrategy
class FetchStrategy
  def fetch_data(_params)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

# Fetch from sample file
class FetchStrategyInline < FetchStrategy
  def fetch_data(*)
    File.read(SAMPLE_RESPONSE_FILE)
  end
end

# Fetch from URL
class FetchStrategyURL < FetchStrategy
  def fetch_data(url)
    uri = URI(url)
    return Net::HTTP.get(uri)
  end
end

# Loads data from URL or Sample file
class ChallengeDataLoader
  attr_writer :fetch_strategy

  def initialize(source = nil)
    @data_source = source || ENV['CHALLENGE_API_URL']
    @fetch_strategy = if @data_source.eql? "SAMPLE"
                        FetchStrategyInline
                      elsif @data_source =~ /^https?:/i
                        FetchStrategyURL
                      else
                        FetchStrategy
                      end
  end

  def load_data
    source = @fetch_strategy.new.fetch_data(@data_source)
    return JSON.parse(source)
  end
end
