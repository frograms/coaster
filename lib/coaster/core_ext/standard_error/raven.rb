class StandardError
  attr_writer :raven

  alias_method :initialize_original, :initialize
  def initialize(message = nil, cause = $!)
    initialize_original(message, cause)
    @raven = (attributes.delete(:raven) || attributes.delete(:sentry) || {}).with_indifferent_access
  end

  def raven
    @raven ||= {}.with_indifferent_access
  end

  def raven_fingerprint
    (fingerprint || Coaster.default_fingerprint).flatten.map do |fp|
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
    nt = raven.merge(opts)

    nt[:tags] ||= (tags && tags.merge(nt[:tags] || {})) || {}
    nt[:tags] = nt[:tags].merge(environment: Rails.env) if defined?(Rails)
    nt[:level] ||= self.level
    nt[:extra] = attributes.merge(nt[:extra])
    nt
  end

  def capture(options = {})
    return if options.key?(:report) && !options[:report]
    return unless report?
    nt = notes(options)
    Raven.capture_exception(self, level: nt[:level]) do |event|
      event.user.merge!(nt[:user] || {})
      event.tags.merge!(nt[:tags])
      event.extra.merge!(nt[:extra])
      event.fingerprint = raven_fingerprint
    end
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
  #   :report
  #   and others are merged to extra
  alias_method :just_logging, :logging
  def logging(options = {})
    capture(options)
    just_logging(options)
  end

  # https://github.com/getsentry/sentry-ruby/blob/fbbc7a51ed10684d0e8b7bd9d2a1b65a7351c9ef/lib/raven/event.rb#L162
  # sentry use `to_s` as a message
  alias to_origin_s to_s
  def message
    to_origin_s
  end

  def to_s
    str = super # https://ruby-doc.org/core-2.5.1/Exception.html#method-i-to_s
    str = "#{user_message} / #{str}" if user_message.present?
    str
  end
end
