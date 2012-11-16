DEFAULT_TEST_CONFIG_PATH = "/tmp/taketo_test_cfg.rb".freeze

When /^I have the following config$/ do |config|
  @config_path = DEFAULT_TEST_CONFIG_PATH
  File.open(@config_path, "w") do |f|
    f.write(config)
  end
end

When /^I run taketo\s?(.*)$/ do |arguments|
  step "I run `taketo --config=/tmp/taketo_test_cfg.rb #{arguments}`"
end

Then /^the output should contain$/ do |expected|
  assert_partial_output(expected, all_output)
end
