$:.push File.expand_path("../lib", __FILE__)
require 'coaster/version'

Gem::Specification.new do |s|
  s.name = 'coaster'
  s.description = 'Ruby Core Extensions'
  s.version = Coaster::VERSION
  s.platform = Gem::Platform::RUBY
  s.date = '2016-01-09'
  s.summary = 'A little convenient feature for standard library'
  s.homepage = 'http://github.com/frograms/coaster'
  s.authors = ['buzz jung']
  s.email = 'buzz@frograms.com'

  s.files = Dir['**/*'].select{|f| File.file?(f)}
  s.require_path = %w{lib}

  s.add_dependency 'i18n'
  s.add_dependency 'rake'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-stack_explorer'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'shoulda-context'
end
