require 'sinatra'

class FakeAPI < Sinatra::Base
  get '/*' do
    json_response 200, 'api_response.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.join( File.dirname(__FILE__), file_name), 'rb').read
  end
end