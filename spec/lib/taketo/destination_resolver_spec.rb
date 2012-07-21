require File.expand_path('../../../spec_helper', __FILE__)
require 'taketo/destination_resolver'
require 'taketo/support/named_nodes_collection'

include Taketo

describe "DestinationResolver" do
  let(:server1) { stub(:Server, :name => :s1) }
  let(:server2) { stub(:Server, :name => :s2) }
  let(:server3) { stub(:Server, :name => :s3) }
  let(:server4) { stub(:Server, :name => :s4) }
  let(:config) do
    stub(:Config, :projects => list(
      stub(:name => :foo, :environments => list(
        stub(:name => :bar, :servers => list(server1))
      )),
      stub(:name => :baz, :environments => list(
        stub(:name => :qux, :servers => list(server2))
      )),
      stub(:name => :quux, :environments => list(
        stub(:name => :corge, :servers => list(server3, server4))
      )),
      stub(:name => :grault, :environments => list(
        stub(:name => :garply, :servers => list(anything, anything)),
        stub(:name => :waldo, :servers => list(anything))
      ))
    ))
  end

  context "when project, environment and server specified" do
    it "should return server if it exists" do
      resolver(config, "foo:bar:s1").resolve.should == server1
    end

    it "should raise error if server does not exist" do
      config = stub(:Config, :projects => list())
      expect { resolver(config, "foo:bar:noserver").resolve }.to raise_error(NonExistentDestinationError, /no such/i)
    end
  end

  context "when there are 2 segments in path" do
    context "when there is matching project - environment pair" do
      it "should return server if only one specified" do
        resolver(config, "foo:bar").resolve.should == server1
        resolver(config, "baz:qux").resolve.should == server2
      end

      it "should raise error if there are multiple servers" do
        expect { resolver(config, "quux:corge").resolve }.to raise_error(AmbiguousDestinationError, /servers/i)
      end
    end

    context "when there is no matching project - environment pair" do
      it "should raise error if no such project - environment pair exist" do
        expect { resolver(config, "chunky:bacon").resolve }.to raise_error(NonExistentDestinationError, /project.*environment/i)
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
            expect { resolver(config, "quux").resolve }.to raise_error(AmbiguousDestinationError, /servers/i)
          end
        end
      end

      context "when there are multiple environments" do
        it "should raise error" do
          expect { resolver(config, "grault").resolve }.to raise_error(AmbiguousDestinationError, /environments/i)
        end
      end
    end

    context "when there is no such project" do
      it "should raise error" do
        expect { resolver(config, "chunky").resolve }.to raise_error(NonExistentDestinationError, /project/i)
      end
    end
  end

  context "when passed path is empty" do
    context "when there is no default destination set" do
      context "when there's one project" do
        context "when there's one environment" do
          context "when there's one server" do
            it "should execute command without asking project/environment/server" do
              config = stub(:Config, :default_destination => nil, :projects => list(
                stub(:name => :foo, :environments => list(
                  stub(:name => :bar, :servers => list(
                    server1
                  ))
                ))
              ))

              resolver(config, "").resolve.should == server1
            end
          end

          context "when there are multiple servers" do
            let(:server1) { stub(:Server, :name => :s1) }
            let(:server2) { stub(:Server, :name => :s2) }

            it "should ask for server" do
              config = stub(:Config, :default_destination => nil, :projects => list(
                stub(:name => :foo, :environments => list(
                  stub(:name => :bar, :servers => list(
                    server1, server2
                  ))
                ))
              ))

              expect { resolver(config, "").resolve }.to raise_error AmbiguousDestinationError, /server/i
            end
          end
        end

        context "when there are multiple environments" do
          it "should ask for environment" do
            config = stub(:Config, :default_destination => nil, :projects => list(
              stub(:name => :foo, :environments => list(
                stub(:name => :bar, :servers => [anything]),
                stub(:name => :baz, :servers => [anything])
              ))
            ))

            expect { resolver(config, "").resolve }.to raise_error AmbiguousDestinationError, /environment/i
          end
        end
      end

      context "when there are multiple projects" do
        it "should ask for project" do
          config = stub(:Config, :default_destination => nil, :projects => list(
            stub(:name => :foo, :environments => [anything]),
            stub(:name => :bar, :environments => [anything])
          ))

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


  def resolver(*args)
    DestinationResolver.new(*args)
  end

  def list(*items)
    Taketo::Support::NamedNodesCollection.new(items)
  end

end

