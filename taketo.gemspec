# -*- encoding: utf-8 -*-

$:.unshift File.expand_path('../lib/', __FILE__)

require 'taketo'
require 'date'

Gem::Specification.new do |s|
  s.name = "taketo"
  s.summary = "A tiny helper utility to make access to servers eaiser " \
    "for different projects and environments"
  s.description <<-DESC
    The aim of the project is to aid quick access to often used servers for web-developers

    With config similar to the following, one could make his life easier:

    project :my_project do
      environment :staging do
        server do
          host "192.168.1.1"
          location "/var/www/prj1"
          env :TERM => "xterm-256color"
        end
      end
    end

    put it in ~/.taketo.rc.rb (or wherever you want using --config)
    and `taketo my_project` effectively becomes:
    `ssh -t 192.168.1.1 "cd /var/www/prj1; TERM=xterm-256color RAILS_ENV=staging bash"`

    see http://github.com/v-yarotsky/taketo for additional instructions
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

  s.executables = ["taketo"]
  s.files = Dir.glob("{bin,lib,spec,features}/**/*") + %w[Gemfile Gemfile.lock Rakefile LICENSE.txt README.md VERSION]
  s.require_paths = ["lib"]

  s.add_development_dependency("rspec", "~> 2.11")
  s.add_development_dependency("rake",  "~> 0.9")
  s.add_development_dependency("aruba", "~> 0.4")
  s.add_development_dependency("simplecov", "~> 0.6")
end


