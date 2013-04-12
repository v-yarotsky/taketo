require 'acceptance_spec_helper'

feature "Edit taketo config" do
  scenario "Open config in editor" do
    run "EDITOR='echo editing' taketo --edit-config"
    stdout.should =~ /editing.*taketo.*/
    stderr.should be_empty
    exit_status.should be_success
  end
end


