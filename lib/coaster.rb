require 'oj'
require 'active_support/deprecation'
require 'active_support/deprecator'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash/slice'

module Coaster
  mattr_writer   :logger
  mattr_writer   :default_fingerprint

  DEFAULT_FINGERPRINT = [:default, :class].freeze

  class << self
    def configure
      yield self
    end

    def default_fingerprint
      @@default_fingerprint ||= DEFAULT_FINGERPRINT
    end

    def logger
      return @@logger if defined?(@@logger) && @@logger
      return Rails.logger if defined?(Rails)
      @@logger = Logger.new(STDOUT)
    end
  end

  def logger
    self.class.logger
  end
end

require 'coaster/core_ext'
require 'coaster/rails_ext'
