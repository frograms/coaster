require 'attr_extras'  # gem

class Month
  attr_reader :_year, :_month
  attr_reader :timezone

  class << self
    def from(object, timezone: nil)
      case object
        when Month 
          object.timezone = timezone
          object
        when String then Month.parse(object, timezone: timezone)
        when Array then Month.new(object[0], object[1], timezone: timezone)
        else new(object.year, object.month, timezone: timezone)
      end
    end

    # Month.parse('201601')
    # Month.parse('2016-01')
    def parse(str, timezone: nil)
      date = Date.parse(str)
      from(date, timezone: timezone)
    rescue ArgumentError => e
      if str.instance_variable_defined?(:@_gsub_) && str.instance_variable_get(:@_gsub_)
        raise e, str: str.instance_variable_get(:@_gsub_)
      elsif e.message != 'invalid date'
        raise e, str: str
      end
      str_gsub = str.gsub(/[^\d]/, '')
      str_gsub.insert(4, '0') if str_gsub.length == 5
      str_gsub += '01'
      str_gsub.instance_variable_set(:@_gsub_, str_gsub)
      parse(str_gsub, timezone: timezone)
    end

    def current
      from(Date.current)
    end

    def now
      from(Time.zone.now)
    end
  end

  def initialize(year, month, timezone: nil)
    @_year = year
    @_month = month
    self.timezone = timezone
  end

  def timezone=(tz)
    tz = ActiveSupport::TimeZone[tz] if tz.is_a?(String)
    @timezone = tz || Time.zone
  end

  def year
    Integer(@_year)
  end

  def month
    Integer(@_month)
  end

  def first_date
    @first_date ||= Date.new(year, month, 1)
  end

  def last_date
    @last_date ||= Date.new(year, month, -1)
  end

  def each_date(&block)
     (first_date..last_date).each(&block)
  end

  def first_day
    first_date.day
  end

  def last_day
    last_date.day
  end

  def beginning_of_month
    first_date.in_time_zone(timezone)
  end

  def end_of_month
    last_date.in_time_zone(timezone).end_of_day
  end

  def date_for_day(number)
    Date.new(year, month, number)
  end

  def to_time_range
    beginning_of_month...(later.beginning_of_month)
  end

  def previous
    self.class.from(first_date - 1)
  end

  def later
    self.class.from(last_date + 1)
  end

  def to_s
    first_date.strftime('%Y-%m')
  end
  alias_method :inspect, :to_s

  def -(time)
    case time
    when ActiveSupport::Duration then Month.from(first_date.in_time_zone(timezone) - time)
    else
      Month.from(first_date - time)
    end
  end

  def +(time)
    case time
    when ActiveSupport::Duration then Month.from(first_date.in_time_zone(timezone) + time)
    else
      Month.from(first_date + time)
    end
  end

  def cover?(t)
    to_time_range.cover?(t)
  end

  include Comparable
  def <=>(other)
    first_date <=> Month.from(other).first_date
  end

  # Range implement
  def succ
    later
  end
end
