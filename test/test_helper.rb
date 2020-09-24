ENV['DEBUG'] = 'true'

require 'minitest'
require 'pry'

require 'rubygems'
require 'bundler/setup'
require 'coaster'
require 'logger'

class Raven
  def self.capture_exception(*args)
  end
end

Coaster.logger = Logger.new(STDOUT)
Coaster.logger.level = Logger::WARN
