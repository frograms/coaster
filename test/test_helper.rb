ENV['DEBUG'] = 'true'

require 'debug'
require 'minitest'
require 'pry'
require 'pry-stack_explorer'

require 'rubygems'
require 'bundler/setup'
require 'coaster'
require 'logger'

require 'rails'
require 'active_record'

class TestApp < Rails::Application
  config.eager_load = false
end
Rails.application.initialize!

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ":memory:"
load File.expand_path('../support/schema.rb', __FILE__)
load File.expand_path('../support/models.rb', __FILE__)

class Raven
  def self.capture_exception(*args)
  end
end

Coaster.logger = Logger.new(STDOUT)
Coaster.logger.level = Logger::WARN
Coaster.default_fingerprint = %i[digest_message digest_backtrace]
