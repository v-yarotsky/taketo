require 'rubygems'
require 'bundler/setup'
require 'simplecov'
SimpleCov.start

$: << File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'rspec/autorun'

