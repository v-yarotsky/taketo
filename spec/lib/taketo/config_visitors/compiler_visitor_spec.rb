require 'spec_helper'
require 'support/helpers/construct_spec_helper'

module Taketo
  module ConfigVisitors

    describe CompilerVisitor do
      include ConstructsFixtures

      subject(:compiler) { CompilerVisitor.new }

      describe "#visit_server" do
        let(:prj) { project(:prj, [env, prj_server]) }
        let(:env) { environment(:env, [prj_env_server]) }
        let(:prj_env_server) { server(:server) }
        let(:prj_server) { server(:server) }

        let!(:config) do
          config = create_config([prj])

          config.default_server_config = ServerConfig.new(:environment_variables => { :UNTOUCHED => 1, :OVERRIDDEN => :not_overridden })
          env.default_server_config = ServerConfig.new(:environment_variables => { :OVERRIDDEN => :overridden_by_environment })

          config
        end

        it "assigns full paths to config, projects, environments, groups" do
          Support::ConfigTraverser.new(config).visit_depth_first(compiler)
          expect(env.path).to eq("prj:env")
        end

        it "assigns full path to servers" do
          Support::ConfigTraverser.new(config).visit_depth_first(compiler)
          expect(prj_env_server.path).to eq("prj:env:server")
          expect(prj_server.path).to eq("prj:server")
        end

        it "merges configs stack" do
          Support::ConfigTraverser.new(config).visit_depth_first(compiler)
          expect(prj_env_server.environment_variables).to include(:UNTOUCHED => 1, :OVERRIDDEN => :overridden_by_environment)
          expect(prj_server.environment_variables).to include(:UNTOUCHED => 1, :OVERRIDDEN => :not_overridden)
        end

        it "includes own server config on top" do
          prj_env_server.config = ServerConfig.new(:environment_variables => { :OVERRIDDEN => :overridden_by_own_config })
          Support::ConfigTraverser.new(config).visit_depth_first(compiler)
          expect(prj_env_server.environment_variables).to include(:UNTOUCHED => 1, :OVERRIDDEN => :overridden_by_own_config)
        end
      end
    end

  end
end

