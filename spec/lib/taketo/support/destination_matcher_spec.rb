require 'spec_helper'
require 'support/helpers/construct_spec_helper'

module Taketo::Support

  describe DestinationMatcher do
    include ConstructsFixtures

    let!(:server1) { s = server(:s1); s.global_alias = :foo_server_alias; s }
    let!(:environment1) { environment(:bar, [server1]) }
    let!(:project1) { project(:foo, [environment1]) }

    let!(:server2) { server(:s2) }

    let!(:config) { create_config([project1, server2]) }

    subject(:matcher) { DestinationMatcher.new([server1, server2]) }

    describe "#matches" do
      it "returns list of all server paths" do
        expect(matcher.matches).to match_array(%w(foo_server_alias foo:bar:s1 s2))
      end
    end
  end

end

