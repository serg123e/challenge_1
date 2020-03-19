# Visit model
class Visit < ActiveRecord::Base
  has_many :pageviews
end
