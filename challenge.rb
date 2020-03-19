require 'json'
require 'net/http'
require 'yaml'
require 'active_record'
require './models/visit'
require './models/pageview'

SAMPLE_RESPONSE_FILE = File.join(File.dirname(__FILE__),
                                 'spec', 'support', 'api_response.json')

class Challenge
  def evid_cleanup(evid)
    return evid.sub(/\Aevid_/, '')
  end

  def evid_valid?(evid)
    return evid =~ /\A(?:evid_)?[A-z0-9]{8}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{12}\z/ ? true : false
  end

  def fetch_url(url)
    uri = URI.parse(URI.encode(url))
    return Net::HTTP.get(uri)
  end

  def load_data(url = '')
    url ||= ENV['CHALLENGE_API_URL']
    if url.eql? ''
      raise(ArgumentError, 'API URL not defined in CHALLENGE_API_URL')
    end

    source = if url.eql? 'SAMPLE'
               File.read(SAMPLE_RESPONSE_FILE)
             else
               fetch_url(url)
             end
    return JSON.parse(source)
  end

  def initialize
    @visit_id = 0
    @seen_page_id = {}
    @errors = []
  end

  def add_error(str)
    @errors.push(str)
  end

  def parse_data_row(action_details)
    pageviews = []
    @pageview_id = 0
    action_details.each do |detail|
      @pageview_id += 1
      pageview = { position: 'visit #%d, pageview #%d' % [@visit_id || 0, @pageview_id],
                   url: detail['url'],
                   title: detail['pageTitle'],
                   time_spent: detail['timeSpent'],
                   timestamp: detail['timestamp'] }
      if @seen_page_id.key? detail['pageId']
        add_error('page "%s" at position %s is not unique, skipping' % [detail['pageId'], pageview[:position]])
        next
      end
      @seen_page_id[detail['pageId']] = true
      pageviews.push(pageview)
    end
    return pageviews.sort { |a, b| a[:timestamp] <=> b[:timestamp] }
  end

  def parse_data(data)
    visits = []
    data.each do |data_row|
      @visit_id += 1

      visit = { pageviews: [],
                evid: data_row['referrerName'],
                vendor_site_id: data_row['idSite'],
                vendor_visit_id: data_row['idVisit'],
                visit_ip: data_row['visitIp'],
                vendor_visitor_id: data_row['visitoriId'] }

      unless evid_valid?(visit[:evid])
        add_error('evid %s is not valid, skipping whole visit #%d' % [visit[:evid], @visit_id])
        next
      end

      visit[:pageviews] = parse_data_row(data_row['actionDetails'])
      visits.push(visit)
    end
    return visits
  end

  def save_data(visits)
    visits_count = 0
    pageviews_count = 0
    visits.each do |visit|
      pageviews = visit.delete(:pageviews)
      new_visit = Visit.create(visit)
      visits_count += 1
      pageviews.each do |pageview|
        new_visit.pageviews.create(pageview)
        pageviews_count += 1
      end
    end
    return { created: { visits: visits_count, pageviews: pageviews_count },
             parsing_errors: @errors }
  end
end
