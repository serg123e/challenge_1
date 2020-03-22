WebMock.disable_net_connect!(allow_localhost: false)
RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /.*/).to_rack(FakeAPI)
  end
end

describe FetchStrategyURL do
  it 'can use Fake API server' do
    strategy = FetchStrategyURL.new
    str = strategy.fetch_data('http://test')
    expect(str).to include('pageId')
  end
end

describe FetchStrategyInline do
  it 'can use SAMPLE data instead of remote server' do
    strategy = FetchStrategyInline.new
    data = strategy.fetch_data('SAMPLE')
    expect(data.length).to be >= 1
  end
end

describe '#Data loading' do
  it 'can load sample data' do
    loader = ChallengeDataLoader.new('SAMPLE')
    data = loader.load_data
    expect(data).to be_instance_of Array
    expect(data.length).to be 4
  end
end

describe 'ENV parsing' do
  it 'tries to load data from extenal URL defined in ENV' do
    ENV['CHALLENGE_API_URL'] = 'http://mock_url'
    expect_any_instance_of(FetchStrategyURL).to receive(:fetch_data).with('http://mock_url').and_return('{}')
    ChallengeDataLoader.new.load_data
  end

  it 'raise an exception if CHALLENGE_API_URL not specified' do
    ENV.delete('CHALLENGE_API_URL')
    expect { Challenge.new.run }.to raise_error NotImplementedError
  end
end
