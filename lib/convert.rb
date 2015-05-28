class Float

  def price dimension
    self.to_f / WeightDimension.weight_group[dimension.to_i][:convert].to_f
  end

  def weight dimension
    self.to_f * WeightDimension.weight_group[dimension.to_i][:convert].to_f
  end
end

class String
  def price dimension
    self.to_f / WeightDimension.weight_group[dimension.to_i][:convert].to_f
  end

  def weight dimension
    self.to_f * WeightDimension.weight_group[dimension.to_i][:convert].to_f
  end
end

class Integer
  def price dimension
    self.to_f / WeightDimension.weight_group[dimension.to_i][:convert].to_f
  end

  def weight dimension
    self.to_f * WeightDimension.weight_group[dimension.to_i][:convert].to_f
  end
end