shared_examples "a construct with nodes" do |name_plural, name_singular|
  specify "#append_#{name_singular} adds a #{name_singular} to " +         # specify "#append_server adds a server to " +
    "the #{name_plural} collection" do                                     #   "the servers collection" do
    node = mock(:name => :foo).as_null_object                              #   server = mock(:name => :foo).as_null_object
    subject.send("append_#{name_singular}", node)                          #   environment.append_server(server)
    expect(subject.send(name_plural)).to include(node)                     #   expect(environment.servers).to include(server)
  end                                                                      # end

  specify "#find_#{name_singular} finds #{name_singular} by name" do       # specify "#find_server finds server by name" do
    subject.send(name_plural).should_receive(:find_by_name).               #   environment.servers.should_receive(:find_by_name).
      with(:foo).and_return(:bar)                                          #     with(:foo).and_return(:bar)
    expect(subject.send("find_#{name_singular}", :foo)).to eq(:bar)        #   expect(environment.find_server(:foo)).to eq(:bar)
  end                                                                      # end
end

