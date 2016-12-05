require 'coaster/core_ext/object_translation'

class StandardError
  cattr_accessor :cleaner, :cause_cleaner

  class << self
    def status
      999999 # Unknown
    end
    alias_method :code, :status

    def http_status
      500
    end

    def title
      t = _translate('.title')
      t.instance_variable_defined?(:@missing) ? nil : t
    end
  end

  attr_accessor :tags, :level, :tkey, :fingerprint

  def initialize(message = nil, cause = $!)
    @fingerprint = Coaster.default_fingerprint.dup
    @tags = {}
    @level = 'error'
    @attributes = HashWithIndifferentAccess.new
    @tkey = nil

    case message
      when Exception
        msg = message
        set_backtrace(message.backtrace)
      when StandardError
        @fingerprint = message.fingerprint
        @tags = message.tags
        @level = message.level
        @tkey = message.tkey
        @attributes = message.attributes
        msg = message
        set_backtrace(message.backtrace)
      when Hash then
        hash = message.with_indifferent_access rescue message
        msg = hash.delete(:m)
        msg = hash.delete(:msg) || msg
        msg = hash.delete(:message) || msg
        @fingerprint = hash.delete(:fingerprint) || hash.delete(:fingerprints)
        @tags = hash.delete(:tags) || hash.delete(:tag)
        @level = hash.delete(:level) || hash.delete(:severity) || @level
        @tkey = hash.delete(:tkey)
        msg = cause.message if msg.nil? && cause
        @attributes.merge!(hash)
      when String then
        msg = message
      when FalseClass, NilClass then
        msg = ''
      else
        msg = message
    end

    @fingerprint = [] unless @fingerprint.is_a?(Array)
    @tags = {} unless @tags.is_a?(Hash)
    msg ||= self.class.title
    super(msg)
  end

  def safe_message
    message || ''
  end

  def status
    self.class.status
  end

  def title
    attributes[:title] || self.class.title
  end

  def attributes
    @attributes ||= HashWithIndifferentAccess.new
    if cause && cause.respond_to?(:attributes) && cause.attributes.is_a?(Hash)
      cause.attributes.merge(@attributes)
    else
      @attributes
    end
  end
  alias_method :attr, :attributes

  def http_status
    attributes[:http_status] || self.class.http_status
  end

  def code
    attributes[:code] || status
  end

  # description is user friendly messages, do not use error's message
  # error message is not user friendly in many cases.
  def description
    dsc = attributes[:description] || attributes[:desc]
    return dsc if dsc
    msg = safe_message.dup
    msg.instance_variable_set(:@raw, true)
    msg
  end
  alias_method :desc, :description

  def object
    attributes[:object] || attributes[:obj]
  end
  alias_method :obj, :object

  def root_cause
    cause.respond_to?(:root_cause) ? cause.root_cause : self
  end

  def to_hash
    hash = @attributes.merge(
      type: self.class.name, status: status,
      http_status: http_status, message: message
    )
    if cause
      if cause.respond_to?(:to_hash)
        hash[:cause] = cause.to_hash
      else
        hash[:cause] = cause
      end
    end
    hash
  end

  def _translate_params
    attributes.merge(
      type: self.class.name, status: status,
      http_status: http_status, message: message
    )
  end

  def to_json
    Oj.dump(to_hash.with_indifferent_access, mode: :compat)
  end

  def to_detail
    lg = "[#{self.class.name}] status:#{status}"
    lg += "\n\tMESSAGE: #{safe_message.gsub(/\n/, "\n\t\t")}"
    instance_variables.each do |var|
      if var.to_s.start_with?('@_')
        next
      elsif var.to_s == '@spell_checker'
        next
      else
        val = instance_variable_get(var)
        val = val.inspect rescue val.to_s
        lg += "\n\t#{var}: #{val}"
      end
    end
    if cause
      if cause.respond_to?(:to_detail)
        lg += "\n\tCAUSE: "
        lg += cause.to_detail.strip.gsub(/\n/, "\n\t")
      else
        lg += "\n\tCAUSE: #{cause.class.name}: #{cause.message.gsub(/\n/, "\n\t\t")}"
      end
      if cause_cleaner && cause.backtrace
        lg += cause_cleaner.clean(cause.backtrace).join("\n\t\t")
      end
    end
    lg << "\n"
  end

  def rails_tag
    (fingerprint || Coaster.default_fingerprint).flatten.map do |fp|
      if fp == true || fp == :class
        self.class.name
      elsif fp == :default || fp == '{{ default }}'
        nil
      else
        fp
      end
    end.compact
  end

  def logging(options = {})
    logger = options[:logger]
    logger = Rails.logger if logger.nil? && defined?(Rails)
    return nil unless logger

    cl = options[:cleaner] || cleaner
    msg = to_detail

    if cl && backtrace
      msg += "\tBACKTRACE:\n\t"
      msg += cl.clean(backtrace).join("\n\t")
    end

    logger.tagged(*rails_tag) do
      if level && logger.respond_to?(level)
        logger.send(level, msg)
      else
        logger.error(msg)
      end
    end
  end
end
