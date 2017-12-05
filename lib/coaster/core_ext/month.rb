require 'attr_extras'  # gem

class Month
  vattr_initialize :year, :month

  class << self
    def from(object)
      case object
        when Month then object
        when String then Month.parse(object)
        when Array then Month.new(object[0], object[1])
        else new(object.year, object.month)
      end
    end

    # Month.parse('201601')
    # Month.parse('2016-01')
    def parse(str)
      date = Date.parse(str)
      from(date)
    rescue ArgumentError => e
      if str.instance_variable_get(:@_gsub_)
        raise e, str: str.instance_variable_get(:@_gsub_)
      elsif e.message != 'invalid date'
        raise e, str: str
      end
      str_gsub = str.gsub(/[^\d]/, '')
      str_gsub.insert(4, '0') if str_gsub.length == 5
      str_gsub += '01'
      str_gsub.instance_variable_set(:@_gsub_, str_gsub)
      parse(str_gsub)
    end

    def current
      from(Date.current)
    end

    def now
      from(Time.zone.now)
    end
  end

  def year
    Integer(@year)
  end

  def month
    Integer(@month)
  end

  def first_date
    Date.new(year, month, 1)
  end

  def last_date
    Date.new(year, month, -1)
  end

  def first_day
    first_date.day
  end

  def last_day
    last_date.day
  end

  def beginning_of_month
    first_date.beginning_of_day
  end

  def end_of_month
    last_date.end_of_day
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
    "#{year}-#{month}"
  end
  alias_method :inspect, :to_s

  def -(time)
    first_date - time
  end

  def +(time)
    first_date + time
  end

  include Comparable
  def <=>(other)
    first_date <=> Month.from(other).first_date
  end
end
