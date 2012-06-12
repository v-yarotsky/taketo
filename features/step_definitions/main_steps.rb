When /^I have the following config in "(.*?)"$/ do |path, config|
  @config_path = path
  File.open(path, "w") do |f|
    f.write(config)
  end
end

Then /^the output should contain$/ do |expected|
  assert_partial_output(expected, all_output)
end
