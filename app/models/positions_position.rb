class PositionsPosition < ActiveRecord::Base
  belongs_to :incoming_offer, class_name: "Position"
  belongs_to :outcoming_offer, class_name: "Position"
end
