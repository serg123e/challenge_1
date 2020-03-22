# saves Visits represented as Array of hashes with nested Pageviews
class ChallengeDataSaver
  attr_reader :visits_count, :pageviews_count
  def initialize
    db_config = YAML.safe_load(File.open(DB_CONFIG_FILE))
    ActiveRecord::Base.establish_connection(db_config)
    @pageviews_count = 0
    @visits_count = 0
  end

  def save_data(visits)
    visits.each do |visit|
      save_row(visit)
    end
    return self
  end

  def save_row(visit)
    pageviews = visit.delete(:pageviews)
    new_visit = Visit.create(visit)

    begin
      @visits_count += 1
      pageviews.each do |pageview|
        new_visit.pageviews.create(pageview)
        @pageviews_count += 1
      end
    end
  end
end
