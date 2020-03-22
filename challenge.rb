require "json"
require "net/http"
require "yaml"
require "active_record"
require "./models/visit"
require "./models/pageview"

SAMPLE_RESPONSE_FILE = File.join(File.dirname(__FILE__), "spec", "support", "api_response.json")
DB_CONFIG_FILE = File.join(File.dirname(__FILE__), "config", "database.yml")

class FetchStrategy
  def fetch_data(params)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

class FetchStrategyInline < FetchStrategy
  def fetch_data(*)
     File.read(SAMPLE_RESPONSE_FILE)
  end
end

class FetchStrategyURL < FetchStrategy
  def fetch_data(url)
    uri = URI(url)
    return Net::HTTP.get(uri)
  end
end

# PORO that loads data from API and saves to MySQL
class Challenge
  attr_writer :fetch_strategy

  def initialize(source=nil)
    @visit_id = 0
    @seen_page_id = {}
    @errors = []
    @data_source = source || ENV['CHALLENGE_API_URL']
    if @data_source.eql? "SAMPLE"
      @fetch_strategy = FetchStrategyInline
    elsif (@data_source =~ /^https?:/i)
      @fetch_strategy = FetchStrategyURL
    else
      @fetch_strategy = FetchStrategy
    end
  end

  def evid_cleanup(evid)
    return evid.sub(/\Aevid_/, "")
  end

  def evid_valid?(evid)
    return evid =~ /\A(?:evid_)?[A-z0-9]{8}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{12}\z/ ? true : false
  end

  def load_data()
    source = @fetch_strategy.new.fetch_data(@data_source)
    return JSON.parse(source)
  end

  def add_error(str)
    @errors.push(str)
  end

  def detail_to_pageview(detail)
    position = "visit #%d, pageview #%d" % [@visit_id || 0, @pageview_id]

    return { position: position,
             url: detail["url"],
             title: detail["pageTitle"],
             time_spent: detail["timeSpent"],
             timestamp: detail["timestamp"] }
  end

  def parse_data_row(action_details)
    pageviews = []
    @pageview_id = 0
    action_details.each do |detail|
      @pageview_id += 1
      pageview = detail_to_pageview(detail)
      if @seen_page_id.has_key? detail["pageId"]
        add_error('page "%s" at position %s is not unique, skipping' % [detail["pageId"], pageview["position"]])
        next
      else
        @seen_page_id[detail["pageId"]] = true
      end

      pageviews.push(pageview)
    end
    return pageviews.sort { |a, b| a[:timestamp] <=> b[:timestamp] }
  end

  def parse_data(data)
    visits = []
    data.each do |data_row|
      @visit_id += 1

      visit = { pageviews: [],
                evid: data_row["referrerName"],
                vendor_site_id: data_row["idSite"],
                vendor_visit_id: data_row["idVisit"],
                visit_ip: data_row["visitIp"],
                vendor_visitor_id: data_row["visitoriId"] }

      unless evid_valid?(visit[:evid])
        add_error("evid %s is not valid, skipping whole visit #%d" % [visit[:evid], @visit_id])
        next
      end

      visit[:pageviews] = parse_data_row(data_row["actionDetails"])
      visits.push(visit)
    end
    return visits
  end

  def save_data(visits)
    pageviews_count = 0
    visits.each do |visit|
      pageviews = visit.delete(:pageviews)
      new_visit = Visit.create(visit)
      pageviews.each do |pageview|
        new_visit.pageviews.create(pageview)
      end
      pageviews_count += pageviews.length
    end
    return { created: { visits: visits.length,
                        pageviews: pageviews_count },
             parsing_errors: @errors }
  end

  def run
    db_config = YAML.safe_load(File.open(DB_CONFIG_FILE))
    ActiveRecord::Base.establish_connection(db_config)
    data = load_data
    visits = parse_data(data)
    return save_data(visits)
  end
end
