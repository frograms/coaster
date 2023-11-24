ENV['DEBUG'] = 'true'

require 'minitest'
require 'pry'
require 'pry-byebug'
require 'pry-stack_explorer'

require 'rubygems'
require 'bundler/setup'
require 'coaster'
require 'logger'

require 'active_record'
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ":memory:"
load File.expand_path('../support/schema.rb', __FILE__)
load File.expand_path('../support/models.rb', __FILE__)
require 'rails'

class Raven
  def self.capture_exception(*args)
  end
end

Coaster.logger = Logger.new(STDOUT)
Coaster.logger.level = Logger::WARN
