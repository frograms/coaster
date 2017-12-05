class Date
  def to_time_range
    beginning_of_day...(self + 1.day).beginning_of_day
  end
end
