require 'coaster/core_ext/object_translation'

class StandardError
  cattr_accessor :cleaner, :cause_cleaner

  class << self
    def status; 999999 end # Unknown
    alias_method :code, :status
    def http_status;  500 end
    def report?;      true end
    def intentional?; false end
    def title; _translate('.title') end

    def before_logging(name, &block)
      @before_logging_blocks ||= {}
      @before_logging_blocks[name] = block
    end
    def before_logging_blocks
      @before_logging_blocks ||= {}
      superclass <= StandardError ? superclass.before_logging_blocks.merge(@before_logging_blocks) : @before_logging_blocks
    end

    def after_logging(name, &block)
      @after_logging_blocks ||= {}
      @after_logging_blocks[name] = block
    end
    def after_logging_blocks
      @after_logging_blocks ||= {}
      superclass <= StandardError ? superclass.after_logging_blocks.merge(@after_logging_blocks) : @after_logging_blocks
    end
  end

  attr_accessor :tags, :level, :tkey, :fingerprint

  def initialize(message = nil, cause = $!)
    @fingerprint = Coaster.default_fingerprint.dup
    @tags = {}
    @level = 'error'
    @attributes = HashWithIndifferentAccess.new
    @attributes.merge!(cause.attributes || {}) if cause && cause.respond_to?(:attributes)
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
      hash[:description] ||= hash.delete(:desc) if hash[:desc].present?
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
    msg ||= self.class._translate
    super(msg)
  end

  def safe_message; message || '' end
  def status;       self.class.status end
  def before_logging_blocks; self.class.before_logging_blocks end
  def after_logging_blocks; self.class.after_logging_blocks end
  def root_cause;   cause.respond_to?(:root_cause) ? cause.root_cause : self end

  def attributes
    return @attributes if defined?(@attributes)
    @attributes = HashWithIndifferentAccess.new
    if cause && cause.respond_to?(:attributes) && cause.attributes.is_a?(Hash)
      @attributes = @attributes.merge(cause.attributes)
    end
    @attributes
  end
  alias_method :attr, :attributes

  def http_status;         attributes[:http_status] || self.class.http_status end
  def http_status=(value); attributes[:http_status] = value end
  def code;         attributes[:code] || status end
  def code=(value); attributes[:code] = value end
  def title;        attributes[:title] || self.class.title end
  def it_might_happen?;      attributes[:it] == :might_happen      end
  def it_should_not_happen?; attributes[:it] == :should_not_happen end
  def report?
    return attributes[:report] if attributes.key?(:report)
    return false if it_might_happen?
    self.class.report?
  end
  def intentional? # not logging in test
    return attributes[:intentional] if attributes.key?(:intentional)
    return true if it_should_not_happen?
    self.class.intentional?
  end
  def object;       attributes[:object] || attributes[:obj] end
  alias_method :obj, :object

  # description is user friendly message as a attribute, do not use error's message
  # error message is not user friendly in many cases.
  def description
    attributes[:description] || attributes[:desc]
  end
  alias_method :desc, :description

  def _translate(*args)
    return description if description.present?
    super
  end

  def _translate_params
    attributes
  end

  # user friendly message, for overid
  def user_message
    return description if description.present?
    _translate
  end

  # another user friendly messages
  def descriptions
    return attributes[:descriptions] if attributes[:descriptions]
    attributes[:descriptions] = {}
    attributes[:descriptions]
  end

  def to_hash
    hash = attributes.merge(
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
    before_logging_blocks.values.each { |blk| instance_exec &blk }

    if !report? || intentional?
      if defined?(Rails)
        return if Rails.env.test?
      else
        return
      end
    end

    logger = options[:logger] || Coaster.logger
    return unless logger

    cl = options[:cleaner] || cleaner
    msg = to_detail

    if cl && backtrace
      bt = cl.clean(backtrace)
      bt = bt[0..2] if intentional?
      msg += "\tBACKTRACE:\n\t"
      msg += bt.join("\n\t")
    end

    if level && logger.respond_to?(level)
      logger.send(level, msg)
    else
      logger.error(msg)
    end
    msg
  ensure
    after_logging_blocks.values.each { |blk| instance_exec &blk }
  end
end
