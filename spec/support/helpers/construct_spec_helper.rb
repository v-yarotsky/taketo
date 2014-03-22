shared_examples "a construct with nodes" do |name_plural, name_singular|
  specify "#add_#{name_singular} adds a #{name_singular} to " +            # specify "#add_server adds a server to " +
    "the #{name_plural} collection" do                                     #   "the servers collection" do
    node = mock(:name => :foo).as_null_object                              #   server = mock(:name => :foo).as_null_object
    subject.send("add_#{name_singular}", node)                             #   environment.add_server(server)
    expect(subject.send(name_plural)).to include(node)                     #   expect(environment.servers).to include(server)
  end                                                                      # end

  specify "#find_#{name_singular} finds #{name_singular} by name" do       # specify "#find_server finds server by name" do
    subject.send(name_plural).should_receive(:find_by_name).               #   environment.servers.should_receive(:find_by_name).
      with(:foo).and_return(:bar)                                          #     with(:foo).and_return(:bar)
    expect(subject.send("find_#{name_singular}", :foo)).to eq(:bar)        #   expect(environment.find_server(:foo)).to eq(:bar)
  end                                                                      # end
end

shared_examples "a node with servers" do
  it_behaves_like "a construct with nodes", :servers, :server

  specify "#has_servers? should perform deep search on child nodes" do
    subject.should_receive(:has_deeply_nested_nodes?).with(:servers)
    subject.has_servers?
  end
end

module ConstructsFixtures
  include Taketo
  include Taketo::Constructs

  [Project, Environment, Group].each do |node_type|
    define_method node_type.name.downcase.gsub(/\w*::/, '') do |name, *args|
      n = node_type.new(name)
      add_nodes(n, args.first || [])
      n
    end
  end

  def create_config(children_nodes = [])
    c = Config.new
    add_nodes(c, children_nodes)
    c
  end

  def create_compiled_config(*args)
    config = create_config(*args)
    traverser = Support::ConfigTraverser.new(config)
    compiler = ConfigVisitors::CompilerVisitor.new
    traverser.visit_depth_first(compiler)
    config
  end

  def server(name, options = {})
    options = options.dup
    s = Server.new(name)
    s.path = options.delete(:path) || s.path
    s.config = s.config.merge(options)
    yield s if block_given?
    s
  end

  def server_command(name, options = {})
    options = options.dup
    c = ServerCommand.new(name)
    c.command = options.delete(:command)
    c.description = options.delete(:description)
    c
  end

  def explicit_server_command(name_and_command)
    ServerCommand.explicit_command(name_and_command)
  end

  def add_nodes(node, children_nodes)
    children_nodes.each { |c| node.add_node(c) }
  end
end

