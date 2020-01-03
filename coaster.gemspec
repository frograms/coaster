$:.push File.expand_path("../lib", __FILE__)
require 'coaster/version'

Gem::Specification.new do |s|
  s.name = 'coaster'
  s.description = 'Ruby Core Extensions'
  s.version = Coaster::VERSION
  s.platform = Gem::Platform::RUBY
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'A little convenient feature for standard library'
  s.homepage = 'http://github.com/frograms/coaster'
  s.authors = ['buzz jung']
  s.email = 'buzz@frograms.com'
  s.licenses = ['MIT']

  s.files = Dir['{app,config,db,lib}/**/*'] + %w(LICENSE Rakefile README.md)
  s.test_files = Dir['test/**/*']
  s.require_path = %w{lib}

  s.add_dependency 'i18n', '>= 1.0'
  s.add_dependency 'rake', '>= 10.0'
  s.add_dependency 'activesupport', '>= 3.0'
  s.add_dependency 'attr_extras', '~> 5.2'

  s.add_development_dependency 'bundler', '~> 1.12'
  s.add_development_dependency 'pry', '~> 0.8'
  s.add_development_dependency 'pry-stack_explorer', '~> 0.4'
  s.add_development_dependency 'pry-byebug', '~> 3.0'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'mocha', '~> 1.0'
  s.add_development_dependency 'shoulda', '~> 3.0'
  s.add_development_dependency 'shoulda-context', '~> 1.0'
end
