require 'spec_helper'
require 'taketo/destination_resolver'
require 'taketo/support/named_nodes_collection'

include Taketo

describe "DestinationResolver" do
  class TestNode
    attr_reader :name, :node_type
    def initialize(node_type, name, *nodes)
      @node_type, @name, @nodes = node_type, name, nodes
    end

    def find(type, name)
      @nodes.detect { |s| s.name == name } or raise KeyError, name.to_s
    end

    def nodes(type)
      @nodes
    end

    def global_alias
      :the_alias if name == :s1 && node_type == :server
    end
  end

  [:project, :environment, :server].each do |node_type|
    define_method node_type do |name, *nodes|
      TestNode.new(node_type, name, *nodes)
    end
  end

  let(:server1) { server(:s1) }
  let(:environment1) { environment(:bar, server1) }
  let(:project1) { project(:foo, environment1) }

  let(:server2) { server(:s2) }
  let(:environment2) { environment(:qux, server2) }
  let(:project2) { project(:baz, environment2) }

  let(:server3) { server(:s3) }
  let(:server4) { server(:s4) }
  let(:environment3) { environment(:corge, server3, server4) }
  let(:project3) { environment(:quux, environment3) }

  let(:environment4) { environment(:garply, server(:s5), server(:s6)) }
  let(:environment5) { environment(:waldo, server(:s7)) }
  let(:project4) { project(:grault, environment4, environment5) }

  let(:config) { TestNode.new(:config, nil, project1, project2, project3, project4) }

  context "when project, environment and server specified" do
    it "should return server if it exists" do
      resolver(config, "foo:bar:s1").resolve.should == server1
    end

    it "should raise error if server does not exist" do
      expect { resolver(config, "foo:bar:noserver").resolve }.to raise_error(NonExistentDestinationError)
    end
  end

  context "when there are 2 segments in path" do
    context "when there is matching project - environment pair" do
      it "should return server if only one specified" do
        resolver(config, "foo:bar").resolve.should == server1
        resolver(config, "baz:qux").resolve.should == server2
      end

      it "should raise error if there are multiple servers" do
        expect { resolver(config, "quux:corge").resolve }.to raise_error(AmbiguousDestinationError)
      end
    end

    context "when there is no matching project - environment pair" do
      it "should raise error if no such project - environment pair exist" do
        expect { resolver(config, "chunky:bacon").resolve }.to raise_error(NonExistentDestinationError)
      end
    end
  end

  context "when there is only one segment in the path" do
    context "when project with given name exists" do
      context "when there's one environment" do
        context "when there's one server" do
          it "should return the server" do
            resolver(config, "foo").resolve.should == server1
          end
        end

        context "when there are multiple servers" do
          it "should raise error" do
            expect { resolver(config, "quux").resolve }.to raise_error(AmbiguousDestinationError)
          end
        end
      end

      context "when there are multiple environments" do
        it "should raise error" do
          expect { resolver(config, "grault").resolve }.to raise_error(AmbiguousDestinationError)
        end
      end
    end

    context "when there is no such project" do
      it "should raise error" do
        expect { resolver(config, "chunky").resolve }.to raise_error(NonExistentDestinationError)
      end
    end
  end

  context "when passed path is empty" do
    context "when there is no default destination set" do
      context "when there's one project" do
        context "when there's one environment" do
          context "when there's one server" do
            it "should execute command without asking project/environment/server" do
              config = TestNode.new(:config, nil, project1)
              config.stub(:default_destination => nil)
              resolver(config, "").resolve.should == server1
            end
          end

          context "when there are multiple servers" do
            it "should ask for server" do
              config = TestNode.new(:config, nil, project3)
              config.stub(:default_destination => nil)
              expect { resolver(config, "").resolve }.to raise_error AmbiguousDestinationError, /server/i
            end
          end
        end

        context "when there are multiple environments" do
          it "should ask for environment" do
            config = TestNode.new(:config, nil, project4)
            config.stub(:default_destination => nil)
            expect { resolver(config, "").resolve }.to raise_error AmbiguousDestinationError, /environment/i
          end
        end
      end

      context "when there are multiple projects" do
        it "should ask for project" do
          config = TestNode.new(:config, nil, project3, project4)
          config.stub(:default_destination => nil)

          expect { resolver(config, "").resolve }.to raise_error AmbiguousDestinationError, /projects/i
        end
      end
    end

    context "when there is default destination" do
      it "should resolve by default destination" do
        config.stub(:default_destination => "foo:bar:s1")
        resolver(config, "").resolve.should == server1
      end
    end
  end

  context "when there is global matching server alias" do
    it "should resolve by alias" do
      resolver(config, "the_alias").resolve.should == server1
    end
  end

  describe "#get_node" do
    it "should return server when path has 3 segments and is correct" do
      resolver(config, "foo:bar:s1").get_node.should == server1
    end

    it "should return environment when path has 2 segments and is correct" do
      resolver(config, "foo:bar").get_node.should == environment1
    end

    it "should return project when path has 1 segment and is correct" do
      resolver(config, "foo").get_node.should == project1
    end

    it "should return the config if path has is empty and there's no default destination" do
      config.stub(:default_destination => nil)
      resolver(config, "").get_node.should == config
    end

    it "should raise NonExistentDestinationError when path is not correct" do
      config.should_receive(:find).with(:project, :i).and_raise(KeyError)
      expect { resolver(config, "i").get_node }.to raise_error(NonExistentDestinationError)
    end
  end

  def resolver(*args)
    DestinationResolver.new(*args)
  end

  def list(*items)
    Taketo::Support::NamedNodesCollection.new(items)
  end

end

