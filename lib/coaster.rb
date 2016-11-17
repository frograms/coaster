require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash/slice'

module Coaster
  mattr_accessor :logger
  mattr_writer   :default_fingerprint

  DEFAULT_FINGERPRINT = [:default, :class]

  class << self
    def configure
      yield self
    end

    def default_fingerprint
      @@default_fingerprint ||= DEFAULT_FINGERPRINT
    end
  end
end

require 'coaster/core_ext'
require 'coaster/backtrace_cleaner'
