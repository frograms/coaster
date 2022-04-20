require 'active_support/backtrace_cleaner'

class Coaster::BacktraceCleaner < ActiveSupport::BacktraceCleaner
  attr_writer :least

  def least
    @least || 10
  end

  private
    def silence(backtrace)
      least_bt = backtrace.shift(least)
      least_bt + super(backtrace)
    end
end
