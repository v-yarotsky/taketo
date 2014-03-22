require 'spec_helper'
require 'support/helpers/construct_spec_helper'

module Taketo
  module Support

    describe DestinationMatcher do
      include ConstructsFixtures

      let!(:server1) { s = server(:s1); s.config.global_alias = :foo_server_alias; s.path = "foo:bar:s1"; s }
      let!(:server2) { s = server(:s2); s.path = "s2"; s }

      subject(:matcher) { DestinationMatcher.new([server1, server2]) }

      describe "#matches" do
        it "returns list of all server paths" do
          expect(matcher.matches).to match_array(%w(foo_server_alias foo:bar:s1 s2))
        end
      end
    end

  end
end

