require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :test

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.verbose = true
end
