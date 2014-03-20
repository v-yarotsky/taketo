require 'spec_helper'

module Taketo::Constructs

  describe Environment do
    subject(:environment) { Environment.new(:foo) }

    it "has name" do
      expect(environment.name).to eq(:foo)
    end

    it "allows only groups and servers as children" do
      environment.allowed_node_types.should =~ [:group, :server]
    end

    it "has RAILS_ENV in default server config" do
      expect(environment.default_server_config.environment_variables[:RAILS_ENV]).to eq("foo")
    end

    it "it holds RAILS_ENV default when assigned a default server config" do
      environment.default_server_config = ::Taketo::Support::ServerConfig.new { |c| c.add_environment_variables(:FOO => :bar) }
      expect(environment.default_server_config.environment_variables).to include(:RAILS_ENV => "foo", :FOO => :bar)
    end

    it "does not overwrite assigned default server config's RAILS_ENV" do
      environment.default_server_config = ::Taketo::Support::ServerConfig.new { |c| c.add_environment_variables(:RAILS_ENV => "bar") }
      expect(environment.default_server_config.environment_variables).to include(:RAILS_ENV => "bar")
    end
  end

end

