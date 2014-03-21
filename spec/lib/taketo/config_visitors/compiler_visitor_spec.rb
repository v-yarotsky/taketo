require 'spec_helper'

module Taketo::ConfigVisitors

  describe CompilerVisitor do
    subject(:compiler) { CompilerVisitor.new }

    describe "#visit_server" do
      let(:project) { ::Taketo::Constructs::Project.new(:prj) }
      let(:environment) { ::Taketo::Constructs::Environment.new(:env) }
      let(:prj_env_server) { ::Taketo::Constructs::Server.new(:server) }
      let(:prj_server) { ::Taketo::Constructs::Server.new(:server) }

      let!(:config) do
        config = ::Taketo::Constructs::Config.new

        config.default_server_config = ::Taketo::Support::ServerConfig.new(:environment_variables => { :UNTOUCHED => 1, :OVERRIDDEN => :not_overridden })
        environment.default_server_config = ::Taketo::Support::ServerConfig.new(:environment_variables => { :OVERRIDDEN => :overridden_by_environment })

        config.add_node(project)
        project.add_node(environment)
        environment.add_node(prj_env_server)
        project.add_node(prj_server)
        config
      end

      it "assigns full paths to config, projects, environments, groups" do
        ::Taketo::Support::ConfigTraverser.new(config).visit_depth_first(compiler)
        expect(environment.path).to eq("prj:env")
      end

      it "assigns full path to servers" do
        ::Taketo::Support::ConfigTraverser.new(config).visit_depth_first(compiler)
        expect(prj_env_server.path).to eq("prj:env:server")
        expect(prj_server.path).to eq("prj:server")
      end

      it "merges configs stack" do
        ::Taketo::Support::ConfigTraverser.new(config).visit_depth_first(compiler)
        expect(prj_env_server.environment_variables).to include(:UNTOUCHED => 1, :OVERRIDDEN => :overridden_by_environment)
        expect(prj_server.environment_variables).to include(:UNTOUCHED => 1, :OVERRIDDEN => :not_overridden)
      end

      it "includes own server config on top" do
        prj_env_server.config = ::Taketo::Support::ServerConfig.new(:environment_variables => { :OVERRIDDEN => :overridden_by_own_config })
        ::Taketo::Support::ConfigTraverser.new(config).visit_depth_first(compiler)
        expect(prj_env_server.environment_variables).to include(:UNTOUCHED => 1, :OVERRIDDEN => :overridden_by_own_config)
      end
    end
  end

end

