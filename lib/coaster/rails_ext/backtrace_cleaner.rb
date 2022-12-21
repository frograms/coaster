require 'active_support/backtrace_cleaner'

class ActiveSupport::BacktraceCleaner
  cattr_accessor :minimum_first, default: 10

  attr_writer :minimum_first

  def minimum_first
    @minimum_first ||= self.class.minimum_first
  end

  private
    alias_method :original_silence, :silence
    def silence(backtrace)
      @silencers.each do |s|
        ix = 0
        backtrace = backtrace.reject do |line|
          ix += 1
          next if ix <= minimum_first
          s.call(line)
        end
      end

      backtrace = backtrace.to_a
      backtrace.insert(minimum_first, 'BacktraceCleaner.minimum_first ... and next silenced backtraces')
      backtrace
    end
end
