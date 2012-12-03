require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/destination_resolver'
require 'taketo/support/named_nodes_collection'

include Taketo

describe "DestinationResolver" do
  include ConstructsFixtures

  let(:server1) { s = server(:s1); s.global_alias = :the_alias; s }
  let(:environment1) { environment(:bar, :servers => server1) }
  let(:project1) { project(:foo, :environments => environment1) }

  let(:server2) { server(:s2) }
  let(:environment2) { environment(:qux, :servers => server2) }
  let(:project2) { project(:baz, :environments => environment2) }

  let(:server3) { server(:s3) }
  let(:server4) { server(:s4) }
  let(:environment3) { environment(:corge, :servers => [server3, server4]) }
  let(:project3) { project(:quux, :environments => environment3) }

  let(:environment4) { environment(:garply, :servers => [server(:s5), server(:s6)]) }
  let(:environment5) { environment(:waldo, :servers => server(:s7)) }
  let(:project4) { project(:grault, :environments => [environment4, environment5]) }

  let(:config) { create_config(:projects => [project1, project2, project3, project4]) }

  context "when project, environment and server specified" do
    it "returns server if it exists" do
      expect(resolver(config, "foo:bar:s1").resolve).to eq(server1)
    end

    it "raises error if server does not exist" do
      expect { resolver(config, "foo:bar:noserver").resolve }.to raise_error(NonExistentDestinationError)
    end
  end

  context "when there are 2 segments in path" do
    context "when there is matching project - environment pair" do
      it "returns server if only one specified" do
        expect(resolver(config, "foo:bar").resolve).to eq(server1)
        expect(resolver(config, "baz:qux").resolve).to eq(server2)
      end

      it "raises error if there are multiple servers" do
        expect { resolver(config, "quux:corge").resolve }.to raise_error(AmbiguousDestinationError)
      end
    end

    context "when there is no matching project - environment pair" do
      it "raises error if no such project - environment pair exist" do
        expect { resolver(config, "chunky:bacon").resolve }.to raise_error(NonExistentDestinationError)
      end
    end
  end

  context "when there is only one segment in the path" do
    context "when project with given name exists" do
      context "when there's one environment" do
        context "when there's one server" do
          it "returns the server" do
            expect(resolver(config, "foo").resolve).to eq(server1)
          end
        end

        context "when there are multiple servers" do
          it "raises error" do
            expect { resolver(config, "quux").resolve }.to raise_error(AmbiguousDestinationError)
          end
        end
      end

      context "when there are multiple environments" do
        it "raises error" do
          expect { resolver(config, "grault").resolve }.to raise_error(AmbiguousDestinationError)
        end
      end
    end

    context "when there is no such project" do
      it "raises error" do
        expect { resolver(config, "chunky").resolve }.to raise_error(NonExistentDestinationError)
      end
    end
  end

  context "when passed path is empty" do
    context "when there is no default destination set" do
      context "when there's one project" do
        context "when there's one environment" do
          context "when there's one server" do
            it "executes command without asking project/environment/server" do
              config = create_config(:projects => project1)
              expect(resolver(config, "").resolve).to eq(server1)
            end
          end

          context "when there are multiple servers" do
            it "asks for server" do
              config = create_config(:projects => project3)
              expect { resolver(config, "").resolve }.to raise_error AmbiguousDestinationError, /s3.*s4/i
            end
          end
        end

        context "when there are multiple environments" do
          it "asks for environment" do
            config = create_config(:projects => project4)
            expect { resolver(config, "").resolve }.to raise_error AmbiguousDestinationError, /garply:s5.*garply:s6.*waldo:s7/i
          end
        end
      end

      context "when there are multiple projects" do
        it "asks for project" do
          config = create_config(:projects => [project3, project4])
          expect { resolver(config, "").resolve }.to raise_error AmbiguousDestinationError, /corge:s3.*corge:s4.*garply:s5.*garply:s6.*waldo:s7/i
        end
      end
    end

    context "when there is default destination" do
      it "resolves by default destination" do
        config.default_destination = "foo:bar:s1"
        expect(resolver(config, "").resolve).to eq(server1)
      end
    end
  end

  context "when there is global matching server alias" do
    it "resolves by alias" do
      expect(resolver(config, "the_alias").resolve).to eq(server1)
    end
  end

  describe "#get_node" do
    it "returns server when path has 3 segments and is correct" do
      expect(resolver(config, "foo:bar:s1").get_node).to eq(server1)
    end

    it "returns environment when path has 2 segments and is correct" do
      expect(resolver(config, "foo:bar").get_node).to eq(environment1)
    end

    it "returns project when path has 1 segment and is correct" do
      expect(resolver(config, "foo").get_node).to eq(project1)
    end

    it "returns the config if path has is empty and there's no default destination" do
      expect(resolver(config, "").get_node).to eq(config)
    end

    it "raises NonExistentDestinationError when path is not correct" do
      expect { resolver(config, "i").get_node }.to raise_error(NonExistentDestinationError)
    end
  end

  def resolver(*args)
    DestinationResolver.new(*args)
  end

end

