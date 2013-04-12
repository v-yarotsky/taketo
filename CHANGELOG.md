The Changelog:
--------------

### v0.2.0 (12.04.2013) ###
* Add --edit-config option to launch editor with taketo config

### v0.2.0.alpha (11.02.2013) ###
* Add support for server groups. The list of servers in particular group can be obtained
  with the following command:
  ```taketo <group_name> --list```

  This becomes especially useful with [tmuxall](https://github.com/v-yarotsky/tmuxall).

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


