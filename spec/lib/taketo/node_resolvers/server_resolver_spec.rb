require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/node_resolvers'

module Taketo::NodeResolvers

  describe ServerResolver do
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

    let(:server5) { server(:s5) }
    let(:server6) { server(:s6) }
    let(:environment4) { environment(:garply, :servers => [server5, server6]) }
    let(:environment5) { environment(:waldo, :servers => server(:s7)) }
    let(:project4) { project(:grault, :environments => [environment4, environment5]) }

    let(:config) { create_config(:projects => [project1, project2, project3, project4]) }

    context "when project, environment and server specified" do
      it "returns server if it exists" do
        expect(resolver(config, "foo:bar:s1").resolve).to eq(server1)
      end

      it "raises error if server does not exist" do
        expect { resolver(config, "foo:bar:noserver").resolve }.to raise_error(Taketo::NonExistentDestinationError)
      end
    end

    context "when there are 2 segments in path" do
      context "when there is matching project - environment pair" do
        it "returns server if only one specified" do
          expect(resolver(config, "foo:bar").resolve).to eq(server1)
          expect(resolver(config, "baz:qux").resolve).to eq(server2)
        end

        it "raises error if there are multiple servers" do
          expect { resolver(config, "quux:corge").resolve }.to raise_error(Taketo::AmbiguousDestinationError)
        end
      end

      context "when there is no matching project - environment pair" do
        it "raises error if no such project - environment pair exist" do
          expect { resolver(config, "chunky:bacon").resolve }.to raise_error(Taketo::NonExistentDestinationError)
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
              expect { resolver(config, "quux").resolve }.to raise_error(Taketo::AmbiguousDestinationError)
            end
          end
        end

        context "when there are multiple environments" do
          it "raises error" do
            expect { resolver(config, "grault").resolve }.to raise_error(Taketo::AmbiguousDestinationError)
          end
        end
      end

      context "when there is no such project" do
        it "raises error" do
          expect { resolver(config, "chunky").resolve }.to raise_error(Taketo::NonExistentDestinationError)
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
                expect { resolver(config, "").resolve }.to raise_error Taketo::AmbiguousDestinationError, /s3.*s4/i
              end
            end
          end

          context "when there are multiple environments" do
            it "asks for environment" do
              config = create_config(:projects => project4)
              expect { resolver(config, "").resolve }.to raise_error Taketo::AmbiguousDestinationError, /garply:s5.*garply:s6.*waldo:s7/i
            end
          end
        end

        context "when there are multiple projects" do
          it "asks for project" do
            config = create_config(:projects => [project3, project4])
            expect { resolver(config, "").resolve }.to raise_error Taketo::AmbiguousDestinationError, /corge:s3.*corge:s4.*garply:s5.*garply:s6.*waldo:s7/i
          end
        end
      end

      context "when there is default destination" do
        it "resolves by default destination" do
          config.default_destination = "foo:bar:s1"
          expect(resolver(config, "").resolve).to eq(server1)
        end
      end

      context "when there is exact match and partial match" do
        it "resolves to exact match" do
          s1 = server(:server1)
          s10 = server(:server10)
          config = create_config(:servers => [s1, s10])
          expect(resolver(config, "server1").resolve).to eq(s1)
        end
      end
    end

    context "when there is global matching server alias" do
      it "resolves by alias" do
        expect(resolver(config, "the_alias").resolve).to eq(server1)
      end
    end

    def resolver(*args)
      ServerResolver.new(*args)
    end
  end

end

