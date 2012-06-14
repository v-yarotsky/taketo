# encoding: utf-8
require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --tags ~@wip --format pretty -x"
  t.fork = false
end

task :default => [:spec, :features]

