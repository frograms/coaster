require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/attribute_accessors'

module Coaster
  mattr_accessor :logger

  class << self
    def configure
      yield self
    end
  end
end

require 'coaster/core_ext'
