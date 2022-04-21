require 'coaster/core_ext/object_translation'
require 'pp'

class StandardError
  cattr_accessor :cleaner, :cause_cleaner

  DEFAULT_DETAIL_VARS = %i[@attributes @tkey @fingerprint @tags @level]
  DEFAULT_DETAIL_VALUE_PROC = Proc.new{|val| val.inspect}

  class << self
    attr_accessor :detail_value_proc

    def status; 999999 end # Unknown
    alias_method :code, :status
    def http_status;  500 end
    def report?;      true end
    def intentional?; false end
    def title; _translate('.title') end
    def detail_vars; @detail_vars ||= DEFAULT_DETAIL_VARS.dup end
    def detail_value_proc; @detail_value_proc ||= superclass.respond_to?(:detail_value_proc) ? superclass.detail_value_proc : DEFAULT_DETAIL_VALUE_PROC end
    def detail_value_simple(val)
      case val
      when Array then val.map{|v| detail_value_simple(v)}
      when Hash then Hash[val.map{|k,v| [k, detail_value_simple(v)]}]
      when String, Numeric, TrueClass, FalseClass then val.to_s
      else val.class.name
      end
    end

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
      @coaster = true # coaster 확장을 사용한 에러임을 확인할 수 있음.
      hash = message.with_indifferent_access rescue message
      msg = hash.delete(:m)
      msg = hash.delete(:msg) || msg
      msg = hash.delete(:message) || msg
      hash[:description] ||= hash.delete(:desc) if hash[:desc].present?
      @fingerprint = hash.delete(:fingerprint) || hash.delete(:fingerprints)
      @tags = hash.delete(:tags) || hash.delete(:tag)
      @level = hash.delete(:level) || hash.delete(:severity) || @level
      @tkey = hash.delete(:tkey)
      @attributes.merge!(hash)
      if @attributes[:description] == :translate
        @attributes.delete(:description)
        @attributes[:description] = _translate
      end
      msg = "#{_translate} (#{msg || self.class.name})"
      msg = "#{msg} {#{cause.message}}" if cause
    when String then
      msg = message
    when FalseClass, NilClass then
      msg = nil
    else
      msg = message
    end

    @fingerprint = [] unless @fingerprint.is_a?(Array)
    @tags = {} unless @tags.is_a?(Hash)
    msg = "{#{cause.message}}" if msg.blank? && cause
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
  def description; attributes[:description] || attributes[:desc] end
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
    return _translate if description.present? || tkey.present?
    return "#{_translate} (#{message})" unless defined?(@coaster)
    message
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

  def detail_vars
    (self.class.detail_vars + (attributes[:detail_vars] || [])).map(&:to_sym).compact.uniq
  end

  def detail_value_proc
    attributes[:detail_value_proc] || self.class.detail_value_proc
  end

  def to_detail
    lg = "[#{self.class.name}] status:#{status}"
    lg += "\n\tMESSAGE: #{safe_message.gsub(/\n/, "\n\t\t")}"
    instance_variables.sort.each do |var|
      if detail_vars.include?(var)
        val = instance_variable_get(var)
        val = detail_value_proc.call(val) rescue val.to_s
        lg += "\n\t#{var}: #{val}"
      elsif var.to_s.start_with?('@__')
        next
      else
        val = instance_variable_get(var)
        lg += "\n\t#{var}: #{self.class.detail_value_simple(val)}"
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

  def cleaned_backtrace(options = {})
    return unless backtrace
    cl = options[:cleaner] || cleaner
    return backtrace unless cl
    bt = cl.clean(backtrace)
    bt = bt[0..2] if intentional?
    bt
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

    msg = to_detail
    if (bt = cleaned_backtrace(options))
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
