require 'coaster/core_ext/object_translation'
require 'coaster/rails_ext/backtrace_cleaner'
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
      when String, Numeric, TrueClass, FalseClass then val
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
      msg = "#{msg} cause{#{cause.message}}" if cause
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

  def to_hash(_h: {}.with_indifferent_access, _depth: 0)
    _h.merge!(attributes)
    _h.merge!(
      type: self.class.name, status: status,
      http_status: http_status, message: message
    )
    if _depth < 4 && cause
      if cause.respond_to?(:to_hash)
        _h[:cause] = cause.to_hash(_depth: _depth + 1)
      else
        _h[:cause_object] = cause
      end
    end
    _h
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

  def to_detail_hash(options: {}.with_indifferent_access, _h: {}.with_indifferent_access, _depth: 0)
    _h.merge!(
      type: self.class.name, status: status,
      http_status: http_status, message: message,
      instance_variables: {}.with_indifferent_access
    )
    instance_variables.sort.each do |var|
      if detail_vars.include?(var)
        val = instance_variable_get(var)
        val = detail_value_proc.call(val) rescue val.to_s
        _h[:instance_variables][var] = val
      elsif var.to_s.start_with?('@__')
        next
      else
        val = instance_variable_get(var)
        _h[:instance_variables][var] = self.class.detail_value_simple(val)
      end
    end
    if backtrace.present?
      if respond_to?(:cleaned_backtrace)
        if (bt = cleaned_backtrace(options))
          _h[:backtrace] = bt
        else
          _h[:backtrace] = backtrace[0...ActiveSupport::BacktraceCleaner.minimum_first]
        end
      else
        _h[:backtrace] = backtrace[0...ActiveSupport::BacktraceCleaner.minimum_first]
      end
    end
    if cause
      if _depth < 4
        if cause.respond_to?(:to_detail_hash)
          _h[:cause] = cause.to_detail_hash(options: options, _depth: _depth + 1)
        else
          cause_h = {
            type: self.class.name, status: status,
            http_status: http_status, message: message,
          }
          cause_h.merge!(backtrace: cause.backtrace[0...ActiveSupport::BacktraceCleaner.minimum_first])
          _h[:cause] = cause_h
        end
      else
        _h[:cause] = 'and more causes...'
      end
    end
    _h
  end

  def to_detail(options = {})
    dh = options[:_dh] || to_detail_hash(options: options)
    lg = "[#{dh[:type]}] status:#{dh[:status]}"
    lg += "\n  MESSAGE: #{dh[:message]&.gsub(/\n/, "\n    ")}"
    dh[:instance_variables].each do |var, val|
      lg += "\n  #{var}: #{val}"
    end
    if (bt = dh[:backtrace] || [])
      lg += "\n  BACKTRACE:\n    "
      lg += bt.join("\n    ")
    end
    if dh[:cause].is_a?(Hash)
      lg += "\n  CAUSE: "
      lg += to_detail(_dh: dh[:cause]).strip.gsub(/\n/, "\n  ")
    elsif dh[:cause].is_a?(String)
      lg += dh[:cause]
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

    msg = to_detail(options)

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
