require File.expand_path('../../../spec_helper', __FILE__)
require 'taketo/taketo_argv_parser'
require 'taketo/support/named_nodes_collection'

include Taketo

describe "TaketoArgvParser" do
  context "when project, environment and server specified" do
    let(:server) { stub(:Server, :name => :baz) }

    it "should return server if it exists" do
      config = stub(:Config, :projects => list(
        stub(:name => :foo, :environments => list(
          stub(:name => :bar, :servers => list(
            server
          ))
        ))
      ))

      parser(config, %w(foo bar baz)).parse.should == server
    end

    it "should raise error if server does not exist" do
      config = stub(:Config, :projects => list())
      expect do
        parser(config, %w(foo bar baz)).parse
      end.to raise_error ArgumentError, /exist/i
    end
  end

  context "when there are two arguments" do
  end

  context "when there are no args" do
    context "when there's one project" do
      context "when there's one environment" do
        context "when there's one server" do
          let(:server) { stub(:Server) }

          it "should execute command without asking project/environment/server" do
            config = stub(:Config, :projects => list(
              stub(:name => :foo, :environments => list(
                stub(:name => :bar, :servers => list(
                  server
                ))
              ))
            ))

            parser(config, []).parse.should == server
          end
        end

        context "when there are multiple servers" do
          let(:server1) { stub(:Server, :name => :s1) }
          let(:server2) { stub(:Server, :name => :s2) }

          it "should ask for server if it's not specified" do
            config = stub(:Config, :projects => list(
              stub(:name => :foo, :environments => list(
                stub(:name => :bar, :servers => list(
                  server1, server2
                ))
              ))
            ))

            expect do
              parser(config, []).parse
            end.to raise_error ArgumentError, /server/i

            parser(config, ["s1"]).parse.should == server1
          end
        end
      end

      context "when there are multiple environments" do
        context "when environment not specified" do
          it "should ask for environment"
        end
      end
    end
  end

  def parser(*args)
    TaketoArgvParser.new(*args)
  end

  def list(*items)
    Taketo::Support::NamedNodesCollection.new(items)
  end

end

