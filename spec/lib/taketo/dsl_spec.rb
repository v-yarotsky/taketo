require 'spec_helper'
require 'support/helpers/dsl_spec_helper'
require 'taketo/dsl'

include Taketo

describe "DSL" do
  extend DSLSpec
  include DSLSpec

  shared_examples_for "a scoped construct" do |name, parents, with_block|
    parents = Array(parents)

    parents.each do |parent_scope_name|
      scopes[parent_scope_name].each do |parent_scope_variant|
        it { should be_appropriate_construct(name, :foo).with_block(with_block).under(parent_scope_variant) }
      end
    end

    scopes.except(*parents).each do |inappropriate_scopes|
      inappropriate_scopes.each do |inappropriate_scope_variant|
        it { should_not be_appropriate_construct(name, :foo).with_block(with_block).under(inappropriate_scope_variant) }
      end
    end
  end

  shared_examples_for "a scope" do |scope_name, parent_scope_names|
    it_behaves_like "a scoped construct", scope_name, Array(parent_scope_names), true

    Array(parent_scope_names).each do |parent_scope_name|
      parent_scope_variants = scopes[parent_scope_name]

      context "under #{parent_scope_name} #{parent_scope_variants.inspect}" do
        it { should enclose_scope(scope_name).under(parent_scope_variants) }

        define_method :within_parent_dsl do |&block|
          parent_scope_variants.each do |parent_scope_variant|
            dsl(parent_scope_variant, factory.create(parent_scope_name)) do |c|
              stub_find_or_create_scope_object(c, scope_name, :bar)
              block.call(c)
            end
          end
        end

        it "creates a #{scope_name} under #{parent_scope_name} and set it as current scope object" do
          within_parent_dsl do |c|
            c.send(scope_name, :bar) do
              expect(c.current_scope_object).to eq(factory.send(scope_name))
            end
          end
        end

        it "does not leak #{scope_name} as current scope object" do
          within_parent_dsl do |c|
            c.send(scope_name, :bar) do
              expect(c.current_scope_object).to eq(factory.send(scope_name))
            end
            expect(c.current_scope_object).not_to eq(factory.send(scope_name))
          end
        end

        it "adds a #{scope_name} to the #{parent_scope_name}'s #{scope_name}s collection" do
          within_parent_dsl do |c|
            c.current_scope_object.should_receive("append_#{scope_name}").
              with(factory.send(scope_name))
            c.send(scope_name, :bar) {}
          end
        end

        it "sets #{scope_name}'s parent to the #{parent_scope_name} scope object" do
          within_parent_dsl do |c|
            factory.send(scope_name).should_receive(:parent=).with(c.current_scope_object)
            c.send(scope_name, :bar) {}
          end
        end
      end
    end
  end

  shared_examples "a scoped method" do |attribute_name, parent_scope_names, parent_scope_method, example_value|
    it_behaves_like "a scoped construct", attribute_name, parent_scope_names, false

    Array(parent_scope_names).each do |parent_scope_name|
      scopes[parent_scope_name].each do |parent_scope_variant|
        it "calls #{parent_scope_method} on current #{parent_scope_name}" do
          dsl(parent_scope_variant, factory.create(parent_scope_name, :foo)) do |c|
            factory.send(parent_scope_name).should_receive(parent_scope_method).with(example_value)
            c.send(attribute_name, example_value)
          end
        end
      end
    end
  end

  describe "#default_destination" do
    it_behaves_like "a scoped method", :default_destination, :config, :default_destination=, "foo:bar:baz"
  end

  describe "#default_server_config" do
    it_behaves_like "a scoped construct", :default_server_config, [:config, :project, :environment, :group]

    it "stores a block" do
      scopes[:config].each do |parent_scope_variant|
        dsl(parent_scope_variant, factory.create(:config)) do |c|
          cfg = proc { any_method_call_here }
          factory.config.should_receive(:default_server_config=).with(cfg)
          c.default_server_config(&cfg)
        end
      end
    end
  end

  describe "#shared_server_config" do
    it_behaves_like "a scoped construct", :shared_server_config, :config

    it "stores a block" do
      scopes[:config].each do |parent_scope_variant|
        dsl(parent_scope_variant, factory.create(:config)) do |c|
          cfg = proc { any_method_call_here }
          c.shared_server_config(:foo, &cfg)
          expect(c.shared_server_configs[:foo]).to eq(cfg)
        end
      end
    end
  end

  describe "#include_shared_server_config" do
    it "executes the block on dsl object in server scope for given shared config names" do
      scopes[:server].each do |parent_scope_variant|
        dsl(parent_scope_variant, factory.create(:config)) do |c|
          c.stub(:shared_server_configs => { :foo => proc { call_from_foo }, :bar => proc { call_from_bar } })
          c.should_receive(:call_from_foo).once
          c.should_receive(:call_from_bar).once
          c.include_shared_server_config(:foo, :bar)
        end
      end
    end

    context "when the argument is hash where shared config names are keys" do
      context "when hash values are arrays" do
        it "includes config corresponding to hash key and passes exploded arguments" do
          scopes[:server].each do |parent_scope_variant|
            dsl(parent_scope_variant, factory.create(:config)) do |c|
              c.stub(:shared_server_configs => { :foo => proc { |a, b| any_method_call_here(a, b) } })
              c.should_receive(:any_method_call_here).with(321, 322)
              c.include_shared_server_config(:foo => [321, 322])
            end
          end
        end
      end

      context "when hash values are single values" do
        it "includes config corresponding to hash key and passes the argument" do
          scopes[:server].each do |parent_scope_variant|
            dsl(parent_scope_variant, factory.create(:config)) do |c|
              c.stub(:shared_server_configs => { :foo => proc { |qux| any_method_call_here(qux) } })
              c.should_receive(:any_method_call_here).with(321)
              c.include_shared_server_config(:foo => 321)
            end
          end
        end
      end
    end

    context "whne there are symbol arguments (names of shared configs) and a hash" do
      it "includes config corresponding to symbol arguments and hash keys" do
        scopes[:server].each do |parent_scope_variant|
          dsl(parent_scope_variant, factory.create(:config)) do |c|
            c.stub(:shared_server_configs => { :foo => proc { call_from_foo }, :bar => proc { |qux| call_from_bar(qux) } })
            c.should_receive(:call_from_foo)
            c.should_receive(:call_from_bar).with(123)
            c.include_shared_server_config(:foo, :bar => 123)
          end
        end
      end
    end

    it "raises ConfigError if non-existent config included" do
      scopes[:server].each do |parent_scope_variant|
        dsl(parent_scope_variant, factory.create(:server)) do |c|
          expect { c.include_shared_server_config(:foo) }.to raise_error(Taketo::DSL::ConfigError, "Shared server config 'foo' is not defined!")
        end
      end
    end
  end

  describe "#project" do
    it_behaves_like "a scope", :project, :config
  end

  describe "#environment" do
    it_behaves_like "a scope", :environment, :project
  end

  describe "#group" do
    it_behaves_like "a scope", :group, [:project, :environment, :config]
  end

  describe "#server" do
    it_behaves_like "a scope", :server, [:environment, :config, :project, :group]

    it "evaluates default_server_config" do
      scopes[:environment].each do |parent_scope_variant|
        dsl(parent_scope_variant, factory.create(:environment, :foo)) do |c|
          stub_find_or_create_scope_object(c, :server, :bar)

          default_server_config = proc { some_setup }
          factory.server.stub(:default_server_config => default_server_config)

          c.should_receive(:some_setup)

          c.server(:bar) do
          end
        end
      end
    end

    it "has name optional" do
      scopes[:environment].each do |parent_scope_variant|
        dsl(parent_scope_variant, factory.create(:environment, :foo)) do |c|
          stub_find_or_create_scope_object(c, :server, :default)
          c.server do
            expect(c.current_scope_object.name).to eq(:default)
          end
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

    describe "#default_command" do
      it_behaves_like "a scoped method", :default_command, :server, :default_command=, :tmux
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
      scopes[:project].each do |parent_scope_variant|
        dsl(parent_scope_variant, factory.create_project(:foo)) do |c|
          expect(c.current_scope_object).to eq(factory.project)
        end
      end

      scopes[:server].each do |parent_scope_variant|
        dsl(parent_scope_variant, factory.create_server(:foo)) do |c|
          expect(c.current_scope_object).to eq(factory.server)
        end
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

  def stub_find_or_create_scope_object(dsl_object, scope, name)
    dsl_object.current_scope_object.stub(:find).with(scope, name).and_yield.and_return(factory.create(scope, name))
  end
end

