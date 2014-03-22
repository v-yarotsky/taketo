require 'spec_helper'
require 'support/helpers/construct_spec_helper'

module Taketo
  module NodeResolvers

    describe GroupResolver do
      include ConstructsFixtures

      let(:server1) { s = server(:s1); s.config.global_alias = :the_alias; s }
      let(:environment1) { environment(:bar, [server1]) }
      let(:project1) { project(:foo, [environment1]) }

      let(:server2) { server(:s2) }
      let(:environment2) { environment(:qux, [server2]) }
      let(:project2) { project(:baz, [environment2]) }

      let(:server3) { server(:s3) }
      let(:server4) { server(:s4) }
      let(:environment3) { environment(:corge, [server3, server4]) }
      let(:project3) { project(:quux, [environment3]) }

      let(:server5) { server(:s5) }
      let(:server6) { server(:s6) }
      let(:environment4) { environment(:garply, [server5, server6]) }
      let(:environment5) { environment(:waldo, [server(:s7)]) }
      let(:project4) { project(:grault, [environment4, environment5]) }

      let(:config) { create_compiled_config([project1, project2, project3, project4]) }

      describe "#resolve" do
        it "does not resolve to server" do
          expect { resolver(config, "foo:bar:s1").resolve }.to raise_error(NonExistentDestinationError)
        end

        it "returns environment when path has 2 segments and is correct" do
          expect(resolver(config, "foo:bar").resolve).to eq(environment1)
        end

        it "returns project when path has 1 segment and is correct" do
          expect(resolver(config, "foo").resolve).to eq(project1)
        end

        it "returns the config if path has is empty and there's no default destination" do
          expect(resolver(config, "").resolve).to eq(config)
        end

        it "raises NonExistentDestinationError when path is not correct" do
          expect { resolver(config, "i").resolve }.to raise_error(NonExistentDestinationError)
        end
      end

      def resolver(*args)
        GroupResolver.new(*args)
      end
    end

  end
end

