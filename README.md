Take Me To
==========

[![Build Status](https://secure.travis-ci.org/v-yarotsky/taketo.png)](http://travis-ci.org/v-yarotsky/taketo)
[![Coverage Status](https://coveralls.io/repos/v-yarotsky/taketo/badge.png?branch=master)](https://coveralls.io/r/v-yarotsky/taketo)
[![Code Climate](https://codeclimate.com/github/v-yarotsky/taketo.png)](https://codeclimate.com/github/v-yarotsky/taketo)
[![Gem Version](https://badge.fury.io/rb/taketo.png)](http://badge.fury.io/rb/taketo)

A tiny helper utility to make access to servers easier for different projects and environments.

Taketo is known to work on:

* ree 1.8.7
* MRI 1.9.2
* MRI 1.9.3
* MRI 2.0.0

Important note:
---------------

The project is currently being actively developed, thus it may contain bugs;
backward compatibility is not guaranteed. However, I'll provide instructions on
how to migrate config file in case of breaking changes.

Suggestions and contributions are highly appreciated :)

Installation:
-------------

The installation is as simple as typing ```gem install taketo```
However, I recommend doing a few things for better user experience:

1. In ~/.zshrc (or ~/.bashrc if you use Bash) create an alias for taketo:
   ```alias to="taketo"```
2. In case you use RVM, I recommend to create a wrapper for taketo,
   which would use newest ruby: ```rvm wrapper ruby-1.9.3-p194-perf@global --no-prefix taketo```.
   Of course, you will need to install taketo for corresponding ruby and gemset.
   Also, keep in mind that the fewer gems are installed into the gemset, the faster things will work.
3. In case you use ZSH – install [taketo ZSH completion](https://raw.github.com/v-yarotsky/taketo/master/scripts/zsh/completion/_taketo).
   For [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh) you can put it in ~/.oh-my-zsh/plugins/taketo/_taketo

Usage:
------

put a config into ```~/.taketo.rc.rb```:

```ruby
  project :my_project do
    environment :staging do
      server :server do
        host "1.2.3.4"
        port 10001
        user "app"
        localtion "/var/app"
        default_command "tmux attach"
        env :TERM => "xterm-256color"
        command :console do
          execute "rails c"
          desc    "Run rails console"
        end
      end
    end
  end
```

Then execute ```taketo my_project:staging:server -c console``` to execute the "rails c" with corresponding environment variables set on desired server
or just ```taketo my_project:staging:server``` to attach to tmux on the server

```default_command``` can be either name of defined server command, or explicit command string. Initially, default command is 'bash'.

To have a brief overview of the config run ```taketo [destination] --view```

Destination resolving works intelligently. Given the following config:

```ruby
  default_destination "my_project2:staging:s2"

  project :my_project do
    environment :staging do
      server :s1 do
        host "1.2.3.4"
      end
    end
    environment :production do
      server :ps1 do
        global_alias :mps1
        host "3.4.5.6"
      end
    end
  end

  project :my_project2 do
    environment :staging do
      server :s2 do
        host "2.3.4.5"
      end
    end
  end
```

```taketo my_project:staging``` will ssh to s1 with host = 1.2.3.4
```taketo my_project2``` will ssh to s2 with host = 2.3.4.5
```taketo mps1``` will ssh to ps1 with host = 3.4.5.6 - note the use of global alias

Note that default destination can be specified via ```default_destination``` config option

You can use shared server configs to reduce duplication:

```ruby
  shared_server_config :my_staging do
    command :console do
      execute "rails c"
      desc "Launch rails console"
    end
  end

  shared_server_config :some_other_shared_config do |folder|
    location File.join("/var", folder)
  end

  project :my_project do
    environment :staging do
      server :s1 do
        host "1.2.3.4"
        include_shared_server_config(:my_staging)
      end

      server :s2 do
        host :s2 do
        include_shared_server_configs(:my_staging, :some_other_shared_config => "qux")
      end
    end
  end
```

This will give you ```console``` commands available both on s1 and s2

Also it's possible to specify default server configuration for any scope (whole config, project or an environment):

```ruby
  default_server_config do
    env :TERM => "xterm-256color"
  end

  project :my_project do
    default_server_config do # will also include global default server config
      location '/var/apps'
    end

    ...
  end

  project :my_project2 do
    ...
  end
```

Default configs are merged appropriately.

Servers can be scoped by groups, i.e.:

```ruby
  project :my_project do
    group :frontends do
      server do
        ...
      end
    end

    group :db do
      ...
    end
  end
```

List of servers included in given group can be obtained this way ```taketo --list <project or environment or group>```
(useful in conjunction with [tmuxall](https://github.com/v-yarotsky/tmuxall) gem)

An SSH config file can be generated from taketo config. To do so, run ```taketo --generate-ssh-config```.

Tips:
-----

Taketo is especially useful in conjunction with [tmuxall](https://github.com/v-yarotsky/tmuxall) gem:

    $ taketo my_project:frontends --list | sed 's/^/taketo /' | tmuxall -n MY_PROJECT_FRONTENDS

