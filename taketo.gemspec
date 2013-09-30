# -*- encoding: utf-8 -*-

$:.unshift File.expand_path('../lib/', __FILE__)

require 'taketo'
require 'date'

Gem::Specification.new do |s|
  s.name = "taketo"
  s.summary = "A tiny helper utility to make access to servers eaiser " \
    "for different projects and environments"
  s.description = <<-DESC
    Taketo is an utility to aid quick access to often used servers for web-developers.
    Taketo uses a config written in ruby using light DSL.
    See http://github.com/v-yarotsky/taketo for additional instructions
  DESC

  s.version = Taketo::VERSION.dup
  s.authors = ["Vladimir Yarotsky"]
  s.date = Date.today.to_s
  s.email = "vladimir.yarotksy@gmail.com"
  s.homepage = "http://github.com/v-yarotsky/taketo"
  s.licenses = ["MIT"]

  s.rubygems_version = "1.8.21"
  s.required_rubygems_version = ">= 1.3.6"
  s.specification_version = 3

  s.files            = `git ls-files`.split($/)
  s.executables      = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files       = s.files.grep(%r{^(spec)/})
  s.require_paths    = ["lib"]
  s.extra_rdoc_files = %w[LICENSE.txt README.md]

  s.add_development_dependency("rspec", "~> 2.14")
  s.add_development_dependency("rake",  "~> 0.9")
  s.add_development_dependency("simplecov", "~> 0.6")
  s.add_development_dependency("open4", "~> 1.3")
end


