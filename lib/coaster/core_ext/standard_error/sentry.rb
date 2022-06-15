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
    nt[:tags][:digest_message] = digest_message if digest_message.present?
    nt[:tags][:digest_backtrace] = digest_backtrace if digest_backtrace.present?
    nt[:level] ||= self.level
    nt[:extra] = attributes.merge(nt[:extra])
    nt
  end

  def capture(options = {})
    return if options.key?(:report) && !options[:report]
    return unless report?
    nt = notes(options)
    Sentry.capture_exception(self, level: nt[:level]) do |scope|
      scope.user.merge!(nt[:user] || {})
      scope.tags.merge!(nt[:tags])
      scope.extra.merge!(nt[:extra])
      scope.set_fingerprint(raven_fingerprint)
    end
  rescue => e
    msg = "#{e.class.name}: #{e.message}"
    msg += "\n\t" + e.backtrace.join("\n\t")
    Sentry.logger.error(msg)
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
end
