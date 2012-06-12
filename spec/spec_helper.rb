require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

$: << File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'rspec/autorun'

require 'taketo/dsl'

Dir[File.dirname(__FILE__) + "/support/matchers/*.rb"].each {|f| require f}

