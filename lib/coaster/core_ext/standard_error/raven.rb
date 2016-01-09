class StandardError
  attr_accessor :raven

  alias_method :initialize_original, :initialize
  def initialize(message = nil, cause = $!)
    initialize_original(message, cause)
    @raven = attributes.delete(:raven) || {}
  end

  def capture(options = {})
    notes = raven.merge(options || {})

    self.tags += Array(notes[:fingerprint])
    notes[:fingerprint] = self.tags
    notes[:level] ||= self.level
    notes[:extra] = (notes[:extra] || {}).merge(attributes)

    Raven.annotate_exception(self, notes)
    Raven.capture_exception(self)
  rescue => e
    msg = "#{e.class.name}: #{e.message}"
    msg += "\n\t" + e.backtrace.join("\n\t")
    Raven.logger.error(msg)
  end

  alias_method :just_logging, :logging
  def logging(options = {})
    capture(options[:raven])
    just_logging(options)
  end
end
