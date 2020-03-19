# require 'spec_helper'
require File.join(File.dirname(__FILE__), '..', 'challenge.rb')

describe '#evid' do
  before(:all) do
    @challenge = Challenge.new
  end

  it 'cleans up evid' do
    expect(
      @challenge.evid_cleanup('evid_966634dc-0bf6-1ff7-f4b6-08000c95c670')
    ).to eq('966634dc-0bf6-1ff7-f4b6-08000c95c670')
  end
  it 'validates evid' do
    expect(@challenge.evid_valid?('evid_966634dc-0bf6-1ff7-f4b6-08000c95c670')).to eq(true)
    expect(@challenge.evid_valid?('966634dc-0bf6-1ff7-f4b6-08000c95c670')).to eq(true)
    expect(@challenge.evid_valid?('0bf6-1ff7-f4b6-08000c95c670')).to eq(false)
  end
end

describe '#api' do
  before(:each) do
    @challenge = Challenge.new
  end
  it 'can use Fake API server' do
    str = @challenge.fetch_url('http://test')
    expect(str).to include('pageId')
  end

  it 'can use SAMPLE data instead of remote server' do
    data = @challenge.load_data('SAMPLE')
    expect(data.length).to be >= 1
  end

  it 'can parse data' do
    data = @challenge.load_data('http://url')
    expect(data).to be_instance_of Array
    expect(data.length).to eq 4
  end

  it 'tries to load data from extenal url in ENV' do
    expect(@challenge).to receive(:fetch_url).with('http://mock_url').and_return(File.read(SAMPLE_RESPONSE_FILE))
    ENV['CHALLENGE_API_URL'] = 'http://mock_url'
    @challenge.load_data
  end
end

describe '#Data processing' do
  before(:all) do
    @challenge = Challenge.new
    @data = JSON.parse(File.read(SAMPLE_RESPONSE_FILE))
    @visits = @challenge.parse_data(@data)
  end

  it 'loads sample data' do
    expect(@data.length).to be 4
  end

  it 'mapping fields well' do
    expect(@visits.first.keys).to include :evid, :pageviews, :vendor_site_id, :vendor_visit_id,
                                          :vendor_visitor_id, :visit_ip
    expect(@visits.first[:pageviews].first.keys).to include :position, :url, :title, :time_spent, :timestamp
  end

  it 'sorts Pageviews by timestamp field, in ascending order.' do
    @visits.each do |visit|
      visit[:pageviews].reduce { |l, r| expect(l[:timestamp] <= r[:timestamp]).to be true; l }
    end
  end

  it 'ensures that pages in pageviews are unique' do
    pageviews = @visits[0][:pageviews] # @challenge.parse_data_row( @data[0]["actionDetails"] )
    # expect(pageviews).to eq ['asd']
    expect(pageviews.length).to eq @data[0]['actionDetails'].length - 1
  end

  it 'ensures that visits with invalid evids are skipping' do
    expect(@visits.length).to eq @data.length - 2
  end

  it 'adds the position field which indicates pageview position in data source array' do
    # pageview#2 because the first timestamp in sample data are older than the first
    expect(@visits.first[:pageviews].first[:position]).to eq 'visit #1, pageview #2'
    expect(@visits.last[:pageviews].last[:position]).to eq 'visit #3, pageview #5'
  end

  it 'store data to a MySQL database' do
    #      expect(ActiveRecord::Base).to receive(:establish_connection)
    mock_visit = double
    mock_pageview = double
    allow(mock_pageview).to receive(:create)
    allow(mock_visit).to receive(:pageviews).and_return mock_pageview

    expect(Visit).to receive(:create).exactly(2).times.and_return(mock_visit)
    expect(mock_pageview).to receive(:create).at_least(15).times # .and_return(true)
    @challenge.save_data(@visits)
  end
end
