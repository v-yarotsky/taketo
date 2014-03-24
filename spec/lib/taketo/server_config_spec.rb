require 'spec_helper'

module Taketo

  describe ServerConfig do
    subject(:server_config) do
      ServerConfig.new(:ssh_command => :ssh,
                       :host => "1.2.3.4",
                       :port => 1234,
                       :username => "root",
                       :default_location => "/var/www/myapp",
                       :identity_file => "/home/user/.ssh/id_rsa.pub",
                       :environment_variables => { :SOME_API_SECRET => "sshhh. secret!" })
    end

    it "can be created without arguments" do
      described_class.new
    end

    describe "#merge!" do
      context "with other ServerConfig" do
        it "merges fields" do
          merged = server_config.merge!(described_class.new(:host => "3.4.5.6"))
          expect(merged.host).to eq("3.4.5.6")
          expect(merged.port).to eq(1234) # didn't change
        end

        it "deeply merges environment_variables" do
          merged = server_config.merge!(described_class.new(:environment_variables => { :BAR => "bar" }))
          expect(merged.environment_variables).to eq(:SOME_API_SECRET => "sshhh. secret!", :BAR => "bar")
        end
      end

      context "with Hash" do
        it "merges fields" do
          merged = server_config.merge!(:host => "3.4.5.6")
          expect(merged.host).to eq("3.4.5.6")
          expect(merged.port).to eq(1234) # didn't change
        end

        it "deeply merges environment_variables" do
          merged = server_config.merge!(:environment_variables => { :BAR => "bar" })
          expect(merged.environment_variables).to eq(:SOME_API_SECRET => "sshhh. secret!", :BAR => "bar")
        end
      end
    end

    specify "#global_alias= converts to string" do
      server_config.global_alias = :foo
      expect(server_config.global_alias).to eq("foo")
    end

    specify "#default_command= converts to string" do
      server_config.default_command = :foo
      expect(server_config.default_command).to eq("foo")
    end

    describe "#ssh_command" do
      it "returns symbol" do
        merged = server_config.merge!(:ssh_command => "mosh")
        expect(merged.ssh_command).to eq(:mosh)
      end

      it "has #ssh_command = :ssh by default" do
        expect(server_config.ssh_command).to eq(:ssh)
      end
    end

    describe "#add_command" do
      it "does not add duplicate commands" do
        server_command1 = ServerCommand.explicit_command("say_hi_1")
        server_command2 = ServerCommand.explicit_command("say_hi_2")
        server_config.add_command(server_command1)
        server_config.add_command(server_command2)
        server_config.add_command(server_command1)
        expect(server_config.commands.to_a).to match_array([server_command1, server_command2])
      end
    end

    describe "#add_environment_variables" do
      it "merges variables with existing ones" do
        server_config.add_environment_variables(:TERM => "xterm-256color")
        expect(server_config.environment_variables).to eql(:TERM => "xterm-256color", :SOME_API_SECRET => "sshhh. secret!")
      end
    end

    describe "#include_shared_server_config" do
      it "merges shared server config"
    end
  end

end
