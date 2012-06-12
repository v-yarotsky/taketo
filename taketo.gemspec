# -*- encoding: utf-8 -*-

$:.unshift File.expand_path('../lib/', __FILE__)

require 'taketo'
require 'date'

Gem::Specification.new do |s|
  s.name = "taketo"
  s.summary = "A tiny helper utility to make access to servers eaiser " \
    "for different projects and environments"

  s.version = Taketo::VERSION.dup
  s.authors = ["Vladimir Yarotsky", "Maksim Yermalovich"]
  s.date = Date.today.to_s
  s.email = "vladimir.yarotksy@gmail.com"
  s.homepage = "http://github.com/v-yarotsky/taketo"
  s.licenses = ["MIT"]

  s.rubygems_version = "1.8.21"
  s.required_rubygems_version = ">= 1.3.6"
  s.specification_version = 3

  s.executables = ["taketo"]
  s.files = Dir.glob("{bin,lib,spec,features}/**/*") + %w[Gemfile Gemfile.lock Rakefile LICENSE.txt README.md VERSION]
  s.require_paths = ["lib"]

  s.add_development_dependency("rspec", "~> 2.10")
  s.add_development_dependency("rake",  "~> 0.9")
  s.add_development_dependency("aruba", "~> 0.4")
  s.add_development_dependency("simplecov", "~> 0.6")
end


