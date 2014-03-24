module Taketo

  class DSL2
    attr_reader :current_scope_object, :config

    def initialize(factory = Taketo::ConstructsFactory.new)
      @factory = factory
      @config = @current_scope_object = factory.create_config
    end

    def configure(filename = nil, &block)
      if filename
        filename = filename.to_s
        config_text = File.read(filename)
        instance_eval config_text, filename, 1
      elsif block
        instance_eval(&block)
      else
        raise ArgumentError, "Either filename or block should be provided"
      end
      @config
    end

    def project(name)
      scope_object = current_scope_object.find_node_by_type_and_name(:project, name) { @factory.create(:project, name) }
      in_scope(scope_object) do |current, parent|
        parent.add_node(current)
        yield
      end
    end

    def environment(name)
      scope_object = current_scope_object.find_node_by_type_and_name(:environment, name) { @factory.create(:environment, name) }
      in_scope(scope_object) do |current, parent|
        parent.add_node(current)
        yield
      end
    end

    def group(name)
      scope_object = current_scope_object.find_node_by_type_and_name(:group, name) { @factory.create(:group, name) }
      in_scope(scope_object) do |current, parent|
        parent.add_node(current)
        yield
      end
    end

    def server(name = :default)
      scope_object = current_scope_object.find_node_by_type_and_name(:server, name) { @factory.create(:server, name) }
      in_scope(scope_object) do |current, parent|
        parent.add_node(current)
        yield
      end
    end

    def command(name)
      scope_object = ServerCommand.new(name.to_s)
      in_scope(scope_object) do |current, parent|
        parent.add_command(current)
        yield
      end
    end

    def default_server_config
      scope_object = current_scope_object.default_server_config
      in_scope(scope_object) do |current, parent|
        yield
      end
    end

    def shared_server_config(name, &block)
      scope_object = ServerConfig.new
      @config.add_shared_server_config(name, block)
    end

    # NON-SCOPES

    def default_destination(destination)
      current_scope_object.default_destination = destination
    end

    def ssh_command(ssh_command)
      current_scope_object.ssh_command = ssh_command
    end

    def host(hostname)
      current_scope_object.host = hostname
    end

    def port(port_number)
      current_scope_object.port = port_number
    end

    def user(username)
      current_scope_object.username = username
    end

    def location(path)
      current_scope_object.default_location = path
    end

    def global_alias(alias_name)
      current_scope_object.global_alias = alias_name
    end

    def env(env)
      current_scope_object.add_environment_variables(env)
    end

    def identity_file(identity_file)
      current_scope_object.identity_file = identity_file
    end

    def default_command(command_name)
      current_scope_object.default_command = command_name
    end

    def execute(command)
      current_scope_object.command = command
    end

    def desc(description)
      current_scope_object.description = description
    end

    def include_shared_server_config(*shared_config_names)
      extract_config_names_and_arguments(shared_config_names).each do |config_name, arguments|
        generated_config = ServerConfig.new
        in_scope(generated_config) do
          instance_exec(*arguments, &@config.shared_server_config(config_name))
        end
        current_scope_object.include_shared_server_config(generated_config)
      end
    end
    alias :include_shared_server_configs :include_shared_server_config

    private

    def in_scope(new_scope_object)
      parent_scope_object, @current_scope_object = @current_scope_object, new_scope_object
      yield current_scope_object, parent_scope_object
      @current_scope_object = parent_scope_object
    end

    def extract_config_names_and_arguments(args)
      hashes, names = args.partition { |arg| arg.is_a? Hash }
      configs_from_hashes = hashes.inject({}, &:merge)
      configs_from_names = Hash[names.map { |config_name| [config_name.to_sym, []] }]
      configs_from_hashes.merge(configs_from_names)
    end
  end

end

