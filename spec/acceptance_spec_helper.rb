require 'open3'
require 'spec_helper'

ENV['PATH'] = "#{File.expand_path('../../bin', __FILE__)}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
ENV['RUBYOPT'] = '-Ilib'
ENV["TAKETO_DEV"] = 'true'

module AcceptanceSpecDSL
  module Feature
    def self.extended(base)
      base.instance_eval do
        alias :feature :describe
      end
    end
  end

  def self.included(base)
    base.instance_eval do
      alias :background :before
      alias :scenario :it
      alias :xscenario :xit
      alias :given :let
      alias :given! :let!
    end
  end
end

module TaketoAcceptanceSpec
  DEFAULT_TEST_CONFIG_PATH = "/tmp/taketo_test_cfg.rb".freeze

  attr_reader :stdout, :stderr, :exit_status

  def create_config(config)
    File.open(DEFAULT_TEST_CONFIG_PATH, "w") do |f|
      f.write(config)
    end
  end
  alias :config_exists :create_config

  def remove_config
    if File.exist?(DEFAULT_TEST_CONFIG_PATH)
      FileUtils.rm(DEFAULT_TEST_CONFIG_PATH)
    end
  end

  def run(command)
    stdin, stdout, stderr, wait_thr = Open3.popen3("#{command} --config #{DEFAULT_TEST_CONFIG_PATH}")
    @stdout = stdout.read.chomp.freeze
    @stderr = stderr.read.chomp.freeze
    @exit_status = wait_thr.value
  ensure
    stdin.close if stdin
    stdout.close if stdout
    stderr.close if stderr
  end

  RSpec.configure do |config|
    config.after(:each) do
      @stdout = nil
      @stderr = nil
      @exit_status = nil
      remove_config
    end
  end
end

extend AcceptanceSpecDSL::Feature

RSpec.configure do |c|
  c.include AcceptanceSpecDSL
  c.include TaketoAcceptanceSpec
end
