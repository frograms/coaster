require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/string'
require 'coaster/core_ext/object_translation'

class StandardError
  cattr_accessor :cleaner

  class << self
    def status
      999999 # Unknown
    end

    def http_status
      500
    end

    def title
      t = _translate('.title')
      t.instance_variable_get(:@missing) ? nil : t
    end
  end

  attr_accessor :tags, :level, :tkey

  def initialize(message = nil, cause = $!)
    @tags = []
    @level = 'error'
    @attributes = HashWithIndifferentAccess.new
    @tkey = nil

    case message
      when Exception
        msg = message
        set_backtrace(message.backtrace)
      when StandardError
        @tags = message.tags
        @level = message.level
        @tkey = message.tkey
        @attributes = message.attributes
        msg = message
        set_backtrace(message.backtrace)
      when Hash then
        hash = message.with_indifferent_access rescue message
        msg = hash[:message]
        msg = hash[:msg] if msg.nil?
        msg = hash[:m] if msg.nil?
        @tags = Array(hash.delete(:tags) || hash.delete(:tag))
        @level = hash.delete(:level) || hash.delete(:severity) || @level
        @tkey = hash.delete(:tkey)
        msg = cause.message if msg.nil? && cause
        @attributes.merge!(hash)
      when String, NilClass then
        msg = message
      when FalseClass then
        msg = false
      else
        msg = message
        @attributes[:object] = message
    end

    msg = nil if msg == false
    super(msg)
    set_backtrace(cause.backtrace) if cause
  end

  def status
    self.class.status
  end

  def title
    attributes[:title] || self.class.title
  end

  def attributes
    if cause && cause.respond_to?(:attributes)
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
    attributes[:code] || self.class.code || http_status
  end

  # description is user friendly messages, do not use error's message
  # error message is not user friendly in many cases.
  def description
    dsc = attributes[:description] || attributes[:desc]
    return dsc if dsc
    msg = message.dup
    msg.instance_variable_set(:@raw, true)
    msg
  end
  alias_method :desc, :description

  def object
    attributes[:object] || attributes[:obj]
  end
  alias_method :obj, :object

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

  def translate_params
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
    lg += "\n\tMESSAGE: #{message.gsub(/\n/, "\n\t\t")}"
    instance_variables.each do |var|
      unless var.to_s.start_with?('@_')
        lg += "\n\t#{var}: #{instance_variable_get(var)}"
      end
    end
    if cause
      if cause.respond_to?(:to_detail)
        lg += "\n\tCAUSE: "
        lg += cause.to_detail.strip.gsub(/\n/, "\n\t")
      else
        lg += "\n\tCAUSE: #{cause.class.name}: #{cause.message.gsub(/\n/, "\n\t\t")}"
      end
    end
    lg << "\n"
  end

  def logging(options = {})
    logger = options[:logger]
    logger = Rails.logger if logger.nil? && defined?(Rails)
    return nil unless logger

    cl = options[:cleaner] || cleaner
    msg = to_detail

    if cl && backtrace
      msg += "\t\t"
      msg += cleaner.clean(backtrace).join("\n\t\t")
    end

    logger.tagged(*tags) do
      if logger.respond_to?(level)
        logger.send(level, msg)
      else
        logger.error(msg)
      end
    end
  end
end
