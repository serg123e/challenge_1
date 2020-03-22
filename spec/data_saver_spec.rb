describe ChallengeDataSaver do
  before(:all) do
    @visits = [{ pageviews: %w[p1], title: 'v1' },
               { pageviews: %w[p2 p3 p4], title: 'v2' },
               { pageviews: %w[p5 p6], title: 'v3' }]
  end

  it 'Iterates structure well and tries to store data' do
    expect(ActiveRecord::Base).to receive(:establish_connection)
    saver = ChallengeDataSaver.new

    mock_visit = double
    mock_pageview = double

    allow(mock_pageview).to receive(:create)
    allow(mock_visit).to receive(:pageviews).and_return mock_pageview

    expect(Visit).to receive(:create).exactly(3).times.and_return(mock_visit)
    expect(mock_pageview).to receive(:create).exactly(6).times # .and_return(true)

    saver.save_data(@visits)
  end
end
