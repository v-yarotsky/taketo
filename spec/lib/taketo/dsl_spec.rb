require File.expand_path('../../../spec_helper', __FILE__)
require 'support/helpers/dsl_spec_helper'
require 'taketo/dsl'

include Taketo

describe "DSL" do
  extend DSLSpec
  include DSLSpec

  shared_examples "a scope" do |scope_name, parent_scope_name|
    parent_scope = scopes[parent_scope_name]

    it { should enclose_scope(scope_name).under(parent_scope) }
    it { should be_appropriate_construct(scope_name, :foo).under(parent_scope) }

    scopes.except(parent_scope_name).each do |inappropriate_scope|
      it { should_not be_appropriate_construct(scope_name, :foo).under(inappropriate_scope) }
    end

    it "should create a #{scope_name} and set it as current scope object" do # it "should create project and set it as current scope object"
      dsl(parent_scope, factory.create(parent_scope_name)) do |c|            #   dsl([:config], factory.create(:config)) do |c|
        stub_find_or_create_scope_object(c, scope_name, :bar)                #     stub_find_or_create_scope_object(c, :project, :bar)
        c.send(scope_name, :bar) do                                          #     c.project(:bar) do
          c.current_scope_object.should_not be_nil                           #       c.current_scope_object.should_not be_nil
          c.current_scope_object.should == factory.send(scope_name)          #       c.current_scope_object.should == factory.project
        end                                                                  #     end
      end                                                                    #   end
    end                                                                      # end

    it "should not leak #{scope_name} as current scope object" do            # it "should not leak project as current scope object"
      dsl(parent_scope, factory.create(parent_scope_name)) do |c|            #   dsl([:config], factory.create(:config)) do |c|
        stub_find_or_create_scope_object(c, scope_name, :bar)                #     stub_find_or_create_scope_object(c, :project, :bar)
        c.send(scope_name, :bar) do                                          #     c.project(:bar) do
          c.current_scope_object.should == factory.send(scope_name)          #       c.current_scope_object.should == factory.project
        end                                                                  #     end
        c.current_scope_object.should_not == factory.send(scope_name)        #     c.current_scope_object.should_not == factory.project
      end                                                                    #   end
    end                                                                      # end

    it "should add a #{scope_name} to the #{parent_scope_name}'s #{scope_name}s collection" do # it "should add a project to the config's projects collection" do
      dsl(parent_scope, factory.create(parent_scope_name)) do |c|                              #   dsl([:config], factory.create(:config)) do |c|
        stub_find_or_create_scope_object(c, scope_name, :bar)                                  #     stub_find_or_create_scope_object(c, :project, :bar)
        c.current_scope_object.should_receive("append_#{scope_name}").                         #     c.current_scope_object.should_receive(:append_project).
          with(factory.send(scope_name))                                                       #       with(factory.project)
        c.send(scope_name, :bar) {}                                                            #     c.project(:bar) {}
      end                                                                                      #   end
    end                                                                                        # end
  end

  shared_examples "a scoped method" do |attribute_name, parent_scope_name, parent_scope_method, example_value|
    parent_scope = scopes[parent_scope_name]

    it { should be_appropriate_construct(attribute_name, example_value).under(parent_scope) }

    scopes.except(parent_scope_name).each do |inaproppriate_scope|
      it { should_not be_appropriate_construct(attribute_name, example_value).under(inaproppriate_scope) }
    end

    it "should call #{parent_scope_method} on current #{parent_scope_name}" do                  # it "should call default_location= on current server" do
      dsl(parent_scope, factory.create(parent_scope_name, :foo)) do |c|                         #   dsl([:config, :project, :environment, :server], factory.create(:server, :foo)) do |c|
        factory.send(parent_scope_name).should_receive(parent_scope_method).with(example_value) #     factory.server.should_receive(:default_location=).with('/var/app/')
        c.send(attribute_name, example_value)                                                   #   c.location "/var/app"
      end                                                                                       # end
    end
  end

  describe "#default_destination" do
    it_behaves_like "a scoped method", :default_destination, :config, :default_destination=, "foo:bar:baz"
  end

  describe "Shared server config" do
    specify "#shared_server_config should store a block" do
      dsl(scopes[:config], factory.create(:config)) do |c|
        cfg = proc { any_method_call_here }
        c.shared_server_config(:foo, &cfg)
        c.shared_server_configs[:foo].should == cfg
      end
    end

    describe "#include_shared_server_config" do
      it "should execute the block on dsl object in server scope" do
        dsl(scopes[:server], factory.create(:server)) do |c|
          c.stub(:shared_server_configs => { :foo => proc { any_method_call_here } })
          c.should_receive(:any_method_call_here)
          c.include_shared_server_config(:foo)
        end
      end

      it "should accept arguments" do
        dsl(scopes[:server], factory.create(:server)) do |c|
          c.stub(:shared_server_configs => { :foo => proc { |qux| any_method_call_here(qux) } })
          c.should_receive(:any_method_call_here).with(321)
          c.include_shared_server_config(:foo, 321)
        end
      end

      it "should raise ConfigError if non-existent config included" do
        dsl(scopes[:server], factory.create(:server)) do |c|
          expect { c.include_shared_server_config(:foo) }.to raise_error(Taketo::DSL::ConfigError, "Shared server config 'foo' is not defined!")
        end
      end
    end
  end

  describe "#project" do
    it_behaves_like "a scope", :project, :config

    describe "#environment" do
      it_behaves_like "a scope", :environment, :project

      describe "#server" do
        it_behaves_like "a scope", :server, :environment

        it "should have name optional" do
          dsl(scopes[:environment], factory.create(:environment, :foo)) do |c|
            stub_find_or_create_scope_object(c, :server, :default)
            c.server do
              c.current_scope_object.name.should == :default
            end
          end
        end

        describe "#host" do
          it_behaves_like "a scoped method", :host, :server, :host=, "127.0.0.2"
        end

        describe "#port" do
          it_behaves_like "a scoped method", :port, :server, :port=, 4096
        end

        describe "#user" do
          it_behaves_like "a scoped method", :user, :server, :username=, "deployer"
        end

        describe "#location" do
          it_behaves_like "a scoped method", :location, :server, :default_location=, "/var/app/"
        end

        describe "#env" do
          it_behaves_like "a scoped method", :env, :server, :env, { :FOO => "bar" }
        end

        describe "#global_alias" do
          it_behaves_like "a scoped method", :global_alias, :server, :global_alias=, "foobared"
        end

        describe "#identity_file" do
          it_behaves_like "a scoped method", :identity_file, :server, :identity_file=, "/home/gor/.ssh/qqq"
        end

        describe "#command" do
          it_behaves_like "a scope", :command, :server

          describe "#execute" do
            it_behaves_like "a scoped method", :execute, :command, :command=, "rails c"
          end

          describe "#desc" do
            it_behaves_like "a scoped method", :desc, :command, :description=, "Run rails console"
          end
        end
      end
    end
  end

  describe "#current_scope_object" do
    it "should be config initially" do
      dsl do |c|
        c.current_scope_object.should == factory.config
      end
    end

    it "should correspond to current scope" do
      dsl(:project, factory.create_project(:foo)) do |c|
        c.current_scope_object.should == factory.project
      end

      dsl(:server, factory.create_server(:foo)) do |c|
        c.current_scope_object.should == factory.server
      end
    end
  end

  describe "#configure" do
    it "should read config from file if filename passed" do
      File.stub(:read => "the config")
      dsl = Taketo::DSL.new(factory)
      dsl.should_receive(:instance_eval) do |config, *args|
        config.should == "the config"
      end
      dsl.configure("path/to/config")
    end

    it "should be configured from block unless filename specified" do
      dsl = Taketo::DSL.new(factory)
      config = proc { }
      dsl.should_receive(:instance_eval).with(&config)
      dsl.configure &config
    end

    it "should raise an error if neither config filename nor block passed" do
      expect do
        Taketo::DSL.new(factory).configure
      end.to raise_error ArgumentError, /(config|block)/
    end

    it "should raise meaningful error if config parse failed"
  end

  def stub_find_or_create_scope_object(scope_object, scope, name)
    scope_object.current_scope_object.should_receive(:find).and_yield.and_return(factory.create(scope, name))
    factory.should_receive(:create).with(scope, name)
  end
end

