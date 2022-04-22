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
      remain_bt = original_silence(backtrace)
      m_bt += ['BacktraceCleaner.minimum_first ... and next silenced backtraces'] + remain_bt if remain_bt.present?
      m_bt
    end
end
