ENV['DEBUG'] = 'true'

require 'minitest'
require 'pry'

require 'rubygems'
require 'bundler/setup'
require 'coaster'

class Raven
  def self.capture_exception(*args)
  end
end
