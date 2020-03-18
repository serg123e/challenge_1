require 'simplecov'
require 'rspec/simplecov'
require 'webmock/rspec'
require 'support/fake_api'

SimpleCov.minimum_coverage 100
SimpleCov.start

WebMock.disable_net_connect!(allow_localhost: false)
RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /.*/).to_rack(FakeAPI)
  end
end

module Enumerable
  def sorted_by?(&block)
    lazy.map(&block).sorted?
  end
end
