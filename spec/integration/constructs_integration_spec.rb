require 'spec_helper'

include Taketo::Constructs

describe "Taketo constructs" do
  it "is possible to use 'em without dsl" do
    config = Taketo::Constructs::Config.new
    proj_x = Project.new(:project_x)
    proj_x_env_staging = Environment.new(:staging)
    proj_x_env_staging_server_default = Server.new(:default).tap { |s| s.host = "1.2.3.4" }
    proj_x_env_production = Environment.new(:production)
    proj_x_env_production_group_frontends = Group.new(:frontends)
    proj_x_env_production_group_frontends_server_1 = Server.new(1)
    proj_x_env_production_group_frontends_server_2 = Server.new(2)
    proj_x_env_production_group_db = Group.new(:db)
    proj_x_env_production_group_db_server_default = Server.new(:default)

    config.add_project proj_x

    proj_x.add_environment proj_x_env_staging
    proj_x.add_environment proj_x_env_production

    proj_x_env_staging.add_server proj_x_env_staging_server_default

    proj_x_env_production.add_group proj_x_env_production_group_frontends
    proj_x_env_production.add_group proj_x_env_production_group_db

    proj_x_env_production_group_frontends.add_server proj_x_env_production_group_frontends_server_1
    proj_x_env_production_group_frontends.add_server proj_x_env_production_group_frontends_server_2

    proj_x_env_production_group_db.add_server proj_x_env_production_group_db_server_default

    proj_x_env_staging_server_default.path.should              == "project_x:staging:default"
    proj_x_env_production_group_frontends_server_1.path.should == "project_x:production:frontends:1"
    proj_x_env_production_group_frontends_server_2.path.should == "project_x:production:frontends:2"
  end
end
