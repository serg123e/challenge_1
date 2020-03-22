# require 'spec_helper'

describe '#Main call' do
  it 'do all required steps' do
    expect(ActiveRecord::Base).to receive(:establish_connection)
    expect_any_instance_of(ChallengeDataLoader).to receive(:load_data)
    expect_any_instance_of(ChallengeDataParser).to receive(:parse_data).and_return([1])
    expect_any_instance_of(ChallengeDataSaver).to receive(:save_row)
    Challenge.new.run
  end
end
