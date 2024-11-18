class Time
  def to_time_range(timezone = ::Time.zone)
    timezone = ActiveSupport::TimeZone[timezone] if timezone.is_a?(String)
    s = self.in_time_zone(timezone).change(usec: 0)
    s...(s + 1.second)
  end

  def beginning_of_range(timezone = ::Time.zone)
    to_time_range(timezone).begin
  end

  def end_of_range(timezone = ::Time.zone)
    to_time_range(timezone).end
  end
end
