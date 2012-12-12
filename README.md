Take Me To
==========

[![Build Status](https://secure.travis-ci.org/v-yarotsky/taketo.png)](http://travis-ci.org/v-yarotsky/taketo)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/v-yarotsky/taketo)

A tiny helper utility to make access to servers easier for different projects and environments.

Taketo is known to work on:

* ree 1.8.7
* MRI 1.9.2
* MRI 1.9.3

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

puts a config into ```~/.taketo.rc.rb```:

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


An SSH config file can be generated from taketo config. To do so, run ```taketo --generate-ssh-config```.



The Changelog:
--------------

### v0.1.2 (12.12.2012) ###
* Fix server aliases bug, bump version to 0.1.2 at 12.12.2012 :)

### v0.1.1 (04.12.2012) ###
* Add basic autocompletion support for ZSH, see scripts/zsh/completion

### v0.1.0 (04.12.2012) ###
* Servers can now be outside projects and environments (userful for standalone servers)
* SSH config is being generated both for hostnames and global aliases

### v0.0.10 (17.11.2012) ###
* Add ability to generate ssh config

### v0.0.9 (17.11.2012) ###
* Add default_command server config option

### v0.0.8 (17.11.2012) ###
* Add per-config, per-project and per-environment default server config support, i.e.
  ```ruby
    default_server_config { env :TERM => 'xterm-256color' }  # Global default server config

    project :p1 do
      default_server_config { env :FOO => 'bar' } # global default server config is merged
      ...
    end
  ```

* Shared server configs can be included without redundant empty-array arguments, i.e.
  ```ruby
    include_shared_server_configs(:foo, :bar, :baz => [:arg1, :arg2], :qux => :arg3)
  ```

### v0.0.7 (08.10.2012) ###
* Add ability to include several shared server config at once
  Use hash as include_shared_server_config parameter to include
  multiple shared server configs with arguments, like:
  ```ruby
    include_shared_server_configs(:foo => :some_arg, :bar => [:arg1, :arg2])
  ```
  or just enumerate them if no arguments needed:
  ```ruby
    include_shared_server_configs(:baz, :quux)
  ```

  NOTE: This change will break your config if you've used parametrized
        shared server configs before; rewrite them using hash-form

### v0.0.6 (26.07.2012) ###
* Add identity_file server config option
* Add shared server config support

### v0.0.5 (24.07.2012) ###
* Add --directory option, which enables specifying directory on remote server upon launch
* Add global_alias config option for servers

### v0.0.4 (22.07.2012) ###
* Add --view option. Now you can view your config quickly: ```taketo my_project:environment:server --view``` or just ```taketo --view```
* Now commands can have description

### v0.0.3 (22.07.2012) ###
* Add default_destination config option
* Add intelligent destination resolving

### v0.0.2 (21.07.2012) ###
* Add ability to define environment variables
* Add support for server commands

### v0.0.1 (13.06.2012) ###
* Initial release
* Support for simplest configs


TO-DO:
------

* Command completion
