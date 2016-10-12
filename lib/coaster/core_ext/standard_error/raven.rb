class StandardError
  attr_accessor :raven

  alias_method :initialize_original, :initialize
  def initialize(message = nil, cause = $!)
    initialize_original(message, cause)
    @raven = (attributes.delete(:raven) || attributes.delete(:sentry) || {}).with_indifferent_access
  end

  def raven_fingerprint
    (fingerprint || Coaster.default_raven_fingerprint).flatten.map do |fp|
      if fp == true || fp == :class
        self.class.name
      elsif fp == :default
        '{{ default }}'
      else
        fp
      end
    end.flatten
  end

  def notes(options = {})
    opts = options ? options.dup : {}
    extra_opts = opts.slice!(:fingerprint, :tags, :level, :extra)
    opts[:extra] = extra_opts.merge(opts[:extra] || {})
    notes = raven.merge(opts)

    notes[:fingerprint] ||= raven_fingerprint
    notes[:tags] ||= (tags && tags.merge(notes[:tags] || {})) || {}
    notes[:tags] = notes[:tags].merge(environment: Rails.env) if defined?(Rails)
    notes[:level] ||= self.level
    notes[:extra] = attributes.merge(notes[:extra])
  end

  def capture(options = {})
    Raven.annotate_exception(self, notes(options))
    Raven.capture_exception(self)
  rescue => e
    msg = "#{e.class.name}: #{e.message}"
    msg += "\n\t" + e.backtrace.join("\n\t")
    Raven.logger.error(msg)
  end

  # options
  #   :logger
  #   :cleaner
  #   :fingerprint
  #   :tags
  #   :level
  #   :extra
  #   and others are merged to extra
  alias_method :just_logging, :logging
  def logging(options = {})
    capture(options)
    just_logging(options)
  end
end
