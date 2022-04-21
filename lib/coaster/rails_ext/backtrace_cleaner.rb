require 'active_support/backtrace_cleaner'

class ActiveSupport::BacktraceCleaner
  attr_writer :minimum_first

  def minimum_first
    @minimum_first ||= 10
  end

  private
    alias_method :original_silence, :silence
    def silence(backtrace)
      m_bt = backtrace.shift(minimum_first)
      m_bt + ['BacktraceCleaner.minimum_first ... and next silenced backtraces'] + original_silence(backtrace)
    end
end
