class Date
  def to_time_range(timezone = ::Time.zone)
    timezone = ActiveSupport::TimeZone[timezone] if timezone.is_a?(String)
    b_day = in_time_zone(timezone)
    b_day...(b_day + 1.day)
  end

  def beginning_of_range(timezone = ::Time.zone)
    to_time_range(timezone).begin
  end

  def end_of_range(timezone = ::Time.zone)
    to_time_range(timezone).end
  end

  def prev_specific_date(day_num)
    raise Date::Error, 'invalid date' if day_num < 1 || day_num > 31

    m = Month.from(self)
    if day_num < day
      begin
        m.date_for_day(day_num)
      rescue Date::Error
        m.last_date
      end
    else
      begin
        m.previous.date_for_day(day_num)
      rescue Date::Error
        m.previous.last_date
      end
    end
  end

  def next_specific_date(day_num)
    raise Date::Error, 'invalid date' if day_num < 1 || day_num > 31

    m = Month.from(self)
    if day < day_num
      if m.last_date.day < day_num
        if day < m.last_date.day
          m.last_date
        else
          begin
            m.later.date_for_day(day_num)
          rescue Date::Error
            m.later.last_date
          end
        end
      else
        begin
          m.date_for_day(day_num)
        rescue Date::Error
          m.last_date
        end
      end
    else
      begin
        m.later.date_for_day(day_num)
      rescue Date::Error
        m.later.last_date
      end
    end
  end
end
