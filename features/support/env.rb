require 'rubygems'
require 'bundler/setup'
require 'aruba/cucumber'
require 'fileutils'

ENV['PATH'] = "#{File.expand_path('../../../bin', __FILE__)}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
ENV['RUBYOPT'] = '-Ilib'
ENV["TAKETO_DEV"] = 'true'

After do
  if defined? @config_path and File.exist?(@config_path)
    FileUtils.rm(@config_path)
  end
end
