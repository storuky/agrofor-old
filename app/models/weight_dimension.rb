class WeightDimension < ActiveRecord::Base
  has_many :positions

  DIMENSIONS = [
    { id: 1, convert: 1, name: "kg" },
    { id: 2, convert: 1000, name: "tonn" },
    { id: 3, convert: 1, name: "liter"},
    { id: 4, convert: 1000, name: "m3"},
    { id: 5, convert: 28.31, name: "ft3" }
  ]

  def title
    I18n.t("weight."+self.name.to_s)
  end

  def self.weight_group
    WeightDimension.all.index_by(&:id)
  end
end
