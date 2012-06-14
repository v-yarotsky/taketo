require File.expand_path('../../../spec_helper', __FILE__)
require 'taketo/config_validator'

include Taketo

describe "ConfigValidator" do
  it "should require at least one project" do
    config = stub(:projects => [])
    expect { validator(config).validate! }.to raise_error ConfigError, /projects/i
  end

  it "should require every project to have at least one environment" do
    project_1 = stub(:Project, :name => :project_1, :environments => [])
    project_2 = stub(:Project, :name => :project_2, :environments => [stub])

    config = stub(:projects => [project_1, project_2])
    expect { validator(config).validate! }.to raise_error ConfigError, /project_1/i

    project_1.stub(:environments => { :e => stub })
    expect { validator(config).validate! }.not_to raise_error ConfigError, /project_1/i
  end

  it "should require every environment to have at least one server" do
    environment_1 = stub(:Environment, :name => :environment_1, :servers => [])
    environment_2 = stub(:Environment, :name => :environment_2, :servers => [stub])
    project_1 = stub(:Project, :name => :project_1, :environments => [environment_1])
    project_2 = stub(:Project, :name => :project_2, :environments => [environment_2])

    config = stub(:projects => [project_1, project_2])
    expect { validator(config).validate! }.to raise_error ConfigError, /environment_1/i

    environment_2.stub(:servers => [stub])
    expect { validator(config).validate! }.not_to raise_error ConfigError, /environment_2/i
  end

  def validator(config)
    Taketo::ConfigValidator.new(config)
  end
end


