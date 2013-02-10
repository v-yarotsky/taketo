require 'acceptance_spec_helper'

feature "Generate SSH config" do
  background { config_exists <<-CONFIG }
    project :foo do
      environment :bar do
        server do
          host "bar.foo.com"
          port 5678
          user "pivo"
          identity_file "~/.ssh/id_rsa"
        end
      end
    end

    project :baz do
      environment :qux do
        server :bart do
          global_alias :bazqux
          host "2.3.4.5"
        end
      end
    end
  CONFIG

  scenario "Generate ssh config" do
    run "taketo --generate-ssh-config"
    stdout.should == <<-SSH_CONFIG.chomp
Host bar.foo.com
Hostname bar.foo.com
Port 5678
User pivo
IdentityFile ~/.ssh/id_rsa

Host bazqux
Hostname 2.3.4.5

Host 2.3.4.5
Hostname 2.3.4.5
    SSH_CONFIG
    exit_status.should be_success
  end
end

