
require 'json'
require 'net/http'
require 'yaml'
require 'active_record'
require './models/visit'
require './models/pageview'

class Challenge
  def evid_cleanup(evid)
    return evid.sub(/\Aevid_/,'')
  end
  def evid_valid?(evid)
    return (evid =~ /\A(?:evid_)?[A-z0-9]{8}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{12}\z/) ? true : false
  end

  def fetch_url(url)
    uri = URI.parse( URI.encode(url) )
    return Net::HTTP.get( uri )
  end

  def load_data(url='')
    if (url.eql?'') then
      url = ENV['CHALLENGE_API_URL'] or raise(ArgumentError, 'API URL not defined in CHALLENGE_API_URL variable nor function parameter')
    end

    source = fetch_url(url)
    return JSON.parse(source)
  end

  def initialize
    @visit_id = 0
    @seen_page_id = {}
  end

  def parse_data_row(action_details)
    # warn(action_details.inspect)

    pageviews = []
    @pageview_id = 0
    action_details.each do |detail|
      @pageview_id += 1
      pageview = { position: 'visit #%d, pageview #%d' % [ @visit_id || 0, @pageview_id ],
                   url: detail['url'],
                   title: detail['pageTitle'],
                   time_spent: detail['timeSpent'],
                   timestamp: detail['timestamp']
      }
      if ( @seen_page_id.has_key? detail['pageId'] ) then
        warn('page "%s" at position %s is not unique, skipping' % [detail['pageId'], pageview[:position]] )
        next
      end
      @seen_page_id[ detail['pageId'] ] = true
      pageviews.push( pageview )
    end
    return pageviews.sort{ |a,b| a[:timestamp] <=> b[:timestamp] }
  end

  def parse_data(data)
    visits = []
    data.each do |data_row|
      @visit_id += 1

      visit = { pageviews: [],
                evid: data_row['referrerName'],
                vendor_site_id: data_row['idSite'],
                vendor_visit_id:data_row['idVisit'],
                visit_ip: data_row['visitIp'],
                vendor_visitor_id: data_row['visitoriId']
      }

      if (!evid_valid?( visit[:evid] )) then
        warn('evid %s is not valid, skipping whole visit #%d' % [visit[:evid], @visit_id ])
        next
      end

      visit[:pageviews] = parse_data_row( data_row['actionDetails'] )
      visits.push( visit )
    end
    return visits
  end

  def save_data(visits)


    db_config = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(db_config)


    visits.each do |visit|
      pageviews = visit.delete(:pageviews)
      new_visit = Visit.create( visit )

      pageviews.each do |pageview|
        new_visit.pageviews.create( pageview )
      end

    end

  end
end