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

The project is currently actively developed, thus it may contain bugs;
backward compatibility is not guaranteed.

Suggestions and contributions are highly appreciated :)

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
or just ```taketo my_project:staging:server``` to open bash

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
        include_shared_server_config(:my_staging, :some_other_shared_config => "qux")
      end
    end
  end
```

This will give you ```console``` commands available both on s1 and s2

The Changelog:
--------------

### v0.0.7 (08.10.2012) ###
* Add ability to include several shared server config at once
  Use hash as include_shared_server_config parameter to include
  multiple shared server configs with arguments, like:
  ```ruby
    include_shared_server_config(:foo => :some_arg, :bar => [:arg1, :arg2])
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

* Shared server configs without arguments
* Global server defaults
* Override default commands per server
* Define servers outside projects and environments
* Export SSH config (i.e. for scp)
* Destination completion
* Command completion
