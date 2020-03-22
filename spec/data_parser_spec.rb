describe '#Data Parser: evid' do
  before(:all) do
    @parser = ChallengeDataParser.new
  end

  it 'cleans up evid' do
    expect(
      @parser.evid_cleanup('evid_966634dc-0bf6-1ff7-f4b6-08000c95c670')
    ).to eq('966634dc-0bf6-1ff7-f4b6-08000c95c670')
  end

  it 'validates evid' do
    expect(@parser.evid_valid?('evid_966634dc-0bf6-1ff7-f4b6-08000c95c670')).to eq(true)
    expect(@parser.evid_valid?('966634dc-0bf6-1ff7-f4b6-08000c95c670')).to eq(true)
    expect(@parser.evid_valid?('0bf6-1ff7-f4b6-08000c95c670')).to eq(false)
  end
end

describe ChallengeDataParser do
  before(:all) do
    @parser = ChallengeDataParser.new
    @data = JSON.parse(File.read(SAMPLE_RESPONSE_FILE))
    @visits = @parser.parse_data(@data)
  end

  it 'mapping fields well' do
    expect(@visits.first.keys).to include :evid, :pageviews, :vendor_site_id, :vendor_visit_id,
                                          :vendor_visitor_id, :visit_ip
    expect(@visits.first[:pageviews].first.keys).to include :position, :url, :title, :time_spent, :timestamp
  end

  it 'sorts Pageviews by timestamp field, in ascending order.' do
    @visits.each do |visit|
      expect(visit[:pageviews].sorted_by?(:timestamp)).to be true
    end
  end

  it 'ensures that pages in pageviews are unique' do
    pageviews = @visits[0][:pageviews]
    expect(pageviews.length).to eq @data[0]['actionDetails'].length - 1
  end

  it 'ensures that visits with invalid evids are skipping' do
    expect(@visits.length).to eq @data.length - 2
  end

  it 'adds the position field which indicates pageview position in data source array' do
    expect(@visits.first[:pageviews].first[:position]).to eq 'visit #1, pageview #2'
    expect(@visits.last[:pageviews].last[:position]).to eq 'visit #3, pageview #5'
  end
end
