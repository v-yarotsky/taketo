require 'spec_helper'
require 'support/helpers/dsl_spec_helper'
require 'taketo/dsl'

include Taketo

describe "DSL" do
  extend DSLSpec
  include DSLSpec

  shared_examples "a scoped construct" do |name, parent_scope_name, with_block|
    parent_scope = scopes[parent_scope_name]
    it { should be_appropriate_construct(name, :foo).with_block(with_block).under(parent_scope) }

    scopes.except(parent_scope_name).each do |inappropriate_scope|
      it { should_not be_appropriate_construct(name, :foo).with_block(with_block).under(inappropriate_scope) }
    end
  end

  shared_examples "a scope" do |scope_name, parent_scope_name|
    parent_scope = scopes[parent_scope_name]

    it_behaves_like "a scoped construct", scope_name, parent_scope_name, true

    it { should enclose_scope(scope_name).under(parent_scope) }

    it "creates a #{scope_name} and set it as current scope object" do       # it "creates project and set it as current scope object"
      dsl(parent_scope, factory.create(parent_scope_name)) do |c|            #   dsl([:config], factory.create(:config)) do |c|
        stub_find_or_create_scope_object(c, scope_name, :bar)                #     stub_find_or_create_scope_object(c, :project, :bar)
        c.send(scope_name, :bar) do                                          #     c.project(:bar) do
          expect(c.current_scope_object).not_to be_nil                       #       expect(c.current_scope_object).not_to be_nil
          expect(c.current_scope_object).to eq(factory.send(scope_name))     #       expect(c.current_scope_object).to eq(factory.project)
        end                                                                  #     end
      end                                                                    #   end
    end                                                                      # end

    it "does not leak #{scope_name} as current scope object" do              # it "does not leak project as current scope object"
      dsl(parent_scope, factory.create(parent_scope_name)) do |c|            #   dsl([:config], factory.create(:config)) do |c|
        stub_find_or_create_scope_object(c, scope_name, :bar)                #     stub_find_or_create_scope_object(c, :project, :bar)
        c.send(scope_name, :bar) do                                          #     c.project(:bar) do
          expect(c.current_scope_object).to eq(factory.send(scope_name))     #       expect(c.current_scope_object).to eq(factory.project)
        end                                                                  #     end
        expect(c.current_scope_object).not_to eq(factory.send(scope_name))   #     expect(c.current_scope_object).not_to eq(factory.project)
      end                                                                    #   end
    end                                                                      # end

    it "adds a #{scope_name} to the #{parent_scope_name}'s #{scope_name}s collection" do   # it "adds a project to the config's projects collection" do
      dsl(parent_scope, factory.create(parent_scope_name)) do |c|                          #   dsl([:config], factory.create(:config)) do |c|
        stub_find_or_create_scope_object(c, scope_name, :bar)                              #     stub_find_or_create_scope_object(c, :project, :bar)
        c.current_scope_object.should_receive("append_#{scope_name}").                     #     c.current_scope_object.should_receive(:append_project).
          with(factory.send(scope_name))                                                   #       with(factory.project)
        c.send(scope_name, :bar) {}                                                        #     c.project(:bar) {}
      end                                                                                  #   end
    end                                                                                    # end
  end

  shared_examples "a scoped method" do |attribute_name, parent_scope_name, parent_scope_method, example_value|
    it_behaves_like "a scoped construct", attribute_name, parent_scope_name, false

    it "calls #{parent_scope_method} on current #{parent_scope_name}" do                        # it "calls default_location= on current server" do
      dsl(scopes[parent_scope_name], factory.create(parent_scope_name, :foo)) do |c|            #   dsl([:config, :project, :environment, :server], factory.create(:server, :foo)) do |c|
        factory.send(parent_scope_name).should_receive(parent_scope_method).with(example_value) #     factory.server.should_receive(:default_location=).with('/var/app/')
        c.send(attribute_name, example_value)                                                   #   c.location "/var/app"
      end                                                                                       # end
    end
  end

  describe "#default_destination" do
    it_behaves_like "a scoped method", :default_destination, :config, :default_destination=, "foo:bar:baz"
  end

  describe "#shared_server_config" do
    it_behaves_like "a scoped construct", :shared_server_config, :config

    it "stores a block" do
      dsl(scopes[:config], factory.create(:config)) do |c|
        cfg = proc { any_method_call_here }
        c.shared_server_config(:foo, &cfg)
        expect(c.shared_server_configs[:foo]).to eq(cfg)
      end
    end
  end

  describe "#include_shared_server_config" do
    it "executes the block on dsl object in server scope for given shared config names" do
      dsl(scopes[:server], factory.create(:server)) do |c|
        c.stub(:shared_server_configs => { :foo => proc { any_method_call_here }, :bar => proc { second_method_call_here } })
        c.should_receive(:any_method_call_here)
        c.should_receive(:second_method_call_here)
        c.include_shared_server_config(:foo, :bar)
      end
    end

    context "when the only argument is hash where shared config names are keys" do
      context "when hash values are arrays" do
        it "includes config corresponding to hash key and passes exploded arguments" do
          dsl(scopes[:server], factory.create(:server)) do |c|
            c.stub(:shared_server_configs => { :foo => proc { |a, b| any_method_call_here(a, b) } })
            c.should_receive(:any_method_call_here).with(321, 322)
            c.include_shared_server_config(:foo => [321, 322])
          end
        end
      end

      context "when hash values are single values" do
        it "includes config corresponding to hash key and passes the argument" do
          dsl(scopes[:server], factory.create(:server)) do |c|
            c.stub(:shared_server_configs => { :foo => proc { |qux| any_method_call_here(qux) } })
            c.should_receive(:any_method_call_here).with(321)
            c.include_shared_server_config(:foo => 321)
          end
        end
      end
    end

    it "raises ConfigError if non-existent config included" do
      dsl(scopes[:server], factory.create(:server)) do |c|
        expect { c.include_shared_server_config(:foo) }.to raise_error(Taketo::DSL::ConfigError, "Shared server config 'foo' is not defined!")
      end
    end
  end

  describe "#project" do
    it_behaves_like "a scope", :project, :config
  end

  describe "#environment" do
    it_behaves_like "a scope", :environment, :project
  end

  describe "#server" do
    it_behaves_like "a scope", :server, :environment

    it "has name optional" do
      dsl(scopes[:environment], factory.create(:environment, :foo)) do |c|
        stub_find_or_create_scope_object(c, :server, :default)
        c.server do
          expect(c.current_scope_object.name).to eq(:default)
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

  describe "#current_scope_object" do
    it "is config initially" do
      dsl do |c|
        expect(c.current_scope_object).to eq(factory.config)
      end
    end

    it "corresponds to current scope" do
      dsl(:project, factory.create_project(:foo)) do |c|
        expect(c.current_scope_object).to eq(factory.project)
      end

      dsl(:server, factory.create_server(:foo)) do |c|
        expect(c.current_scope_object).to eq(factory.server)
      end
    end
  end

  describe "#configure" do
    it "reads config from file if filename passed" do
      File.stub(:read => "the config")
      dsl = Taketo::DSL.new(factory)
      dsl.should_receive(:instance_eval) do |config, *args|
        expect(config).to eq("the config")
      end
      dsl.configure("path/to/config")
    end

    it "is configured from block unless filename specified" do
      dsl = Taketo::DSL.new(factory)
      config = proc { }
      dsl.should_receive(:instance_eval).with(&config)
      dsl.configure &config
    end

    it "raises an error if neither config filename nor block passed" do
      expect do
        Taketo::DSL.new(factory).configure
      end.to raise_error ArgumentError, /(config|block)/
    end

    it "raises meaningful error if config parse failed"
  end

  def stub_find_or_create_scope_object(scope_object, scope, name)
    scope_object.current_scope_object.should_receive(:find).and_yield.and_return(factory.create(scope, name))
    factory.should_receive(:create).with(scope, name)
  end
end

