# Converts a
class ChallengeDataParser
  attr_accessor :errors

  def initialize
    @errors = []
    @visit_id = 0
    @seen_page_id = {}
  end

  def row_to_visit(data_row)
    { pageviews: [],
      evid: data_row["referrerName"],
      vendor_site_id: data_row["idSite"],
      vendor_visit_id: data_row["idVisit"],
      visit_ip: data_row["visitIp"],
      vendor_visitor_id: data_row["visitoriId"] }
  end

  def parse_data_row(data_row)
    if evid_valid?(data_row["referrerName"])
      visit = row_to_visit(data_row)
      pageviews = parse_action_details(data_row["actionDetails"])
      visit[:pageviews] = pageviews.sort { |a, b| a[:timestamp] <=> b[:timestamp] }
      return visit
    else
      add_error("evid %s is not valid, skipping whole visit #%d" % [data_row["referrerName"], @visit_id])
      return false
    end
  end

  def parse_data(data)
    visits = []
    data.each do |data_row|
      @visit_id += 1
      visit = parse_data_row(data_row)
      visits.push(visit) if visit
    end
    return visits
  end

  def parse_action_details(action_details)
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
    return pageviews
  end

  def detail_to_pageview(detail)
    position = "visit #%d, pageview #%d" % [@visit_id || 0, @pageview_id]

    return { position: position,
             url: detail["url"],
             title: detail["pageTitle"],
             time_spent: detail["timeSpent"],
             timestamp: detail["timestamp"] }
  end

  def add_error(str)
    @errors.push(str)
  end

  def evid_valid?(evid)
    return evid =~ /\A(?:evid_)?[A-z0-9]{8}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{4}-[A-z0-9]{12}\z/ ? true : false
  end

  def evid_cleanup(evid)
    return evid.sub(/\Aevid_/, "")
  end
end
