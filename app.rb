# frozen_string_literal: true

require './challenge.rb'

def call
  @challenge = Challenge.new
  data = @challenge.load_data('')
  visits = @challenge.parse_data(data)
  p @challenge.save_data(visits)
end
