require 'spec_helper'

include Taketo::Constructs

describe "Taketo constructs" do
  it "is possible to use 'em without dsl" do
    config = Taketo::Constructs::Config.new
    proj_x = Project.new(:project_x)
    proj_x_env_staging = Environment.new(:staging)
    proj_x_env_staging_server_default = Server.new(:default)
    proj_x_env_production = Environment.new(:production)
    proj_x_env_production_group_frontends = Group.new(:frontends)
    proj_x_env_production_group_frontends_server_1 = Server.new(1)
    proj_x_env_production_group_frontends_server_2 = Server.new(2)
    proj_x_env_production_group_db = Group.new(:db)
    proj_x_env_production_group_db_server_default = Server.new(:default)

    config.add_node proj_x

    proj_x.add_node proj_x_env_staging
    proj_x.add_node proj_x_env_production

    proj_x_env_staging.add_node proj_x_env_staging_server_default

    proj_x_env_production.add_node proj_x_env_production_group_frontends
    proj_x_env_production.add_node proj_x_env_production_group_db

    proj_x_env_production_group_frontends.add_node proj_x_env_production_group_frontends_server_1
    proj_x_env_production_group_frontends.add_node proj_x_env_production_group_frontends_server_2

    proj_x_env_production_group_db.add_node proj_x_env_production_group_db_server_default

    proj_x_env_staging_server_default.path.should              == "project_x:staging:default"
    proj_x_env_production_group_frontends_server_1.path.should == "project_x:production:frontends:1"
    proj_x_env_production_group_frontends_server_2.path.should == "project_x:production:frontends:2"
  end

  it "is possible to define default server configs" do
    config = Taketo::Constructs::Config.new
    config.default_server_config << { :ssh_command => :mosh }

    project = Project.new(:project_x)
    project.default_server_config << { :username => "bender" }

    server = Server.new(:foo)
    server.server_config << { :port => 2345 }

    config.add_node(project)
    project.add_node(server)

    expect(server.ssh_command).to eq(:mosh)
    expect(server.username).to eq("bender")
    expect(server.port).to eq(2345)
  end
end
