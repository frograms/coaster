class StandardError
  attr_accessor :raven

  alias_method :initialize_original, :initialize
  def initialize(message = nil, cause = $!)
    initialize_original(message, cause)
    @raven = (attributes.delete(:raven) || {}).with_indifferent_access
    @raven[:fingerprint] ||= attributes[:fingerprint] || [:default]
  end

  def fingerprint=(*fp)
    raven[:fingerprint] = fp
  end

  def fingerprint
    raven[:fingerprint]
  end

  def capture(options = {})
    notes = raven.merge(options || {})

    notes[:fingerprint] = notes[:fingerprint].flatten.map do |fp|
      if fp == true || fp == :class
        self.class.name
      elsif fp == :default
        '{{ default }}'
      else
        fp
      end
    end
    notes[:tags] ||= {}
    notes[:tags] = notes[:tags].merge(environment: Rails.env) if defined?(Rails)
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
