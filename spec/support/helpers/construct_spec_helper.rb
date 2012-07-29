shared_examples "a construct with nodes" do |name_plural, name_singular|
  specify "#append_#{name_singular} should add a #{name_singular} to " +   # specify "#append_server should add a server to " +
    "the #{name_plural} collection" do                                     #   "the servers collection" do
    node = mock(:name => :foo).as_null_object                              #   server = mock(:name => :foo).as_null_object
    subject.send("append_#{name_singular}", node)                          #   environment.append_server(server)
    subject.send(name_plural).should include(node)                         #   environment.servers.should include(server)
  end                                                                      # end

  specify "#find_#{name_singular} should find #{name_singular} by name" do # specify "#find_server should find server by name" do
    subject.send(name_plural).should_receive(:find_by_name).               #   environment.servers.should_receive(:find_by_name).
      with(:foo).and_return(:bar)                                          #     with(:foo).and_return(:bar)
    subject.send("find_#{name_singular}", :foo).should == :bar             #   environment.find_server(:foo).should == :bar
  end                                                                      # end
end

