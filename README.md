Take Me To
==========

[![Build Status](https://secure.travis-ci.org/v-yarotsky/taketo.png)](http://travis-ci.org/v-yarotsky/taketo)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/v-yarotsky/taketo)

A tiny helper utility to make access to servers easier for different projects and environments.

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
        end
      end
    end
  end
```

Then execute ```taketo my_project staging server -c console``` to execute the "rails c" with corresponding environment variables set on desired server
or just ```taketo my_project staging server``` to open bash

To-Do:
------

* Add support for defaults
* Add support for generating shortcuts

The Changelog:
--------------

### v0.0.2 (21.07.2012) ###
* Add ability to define environment variables
* Add support for server commands

### v0.0.1 (13.06.2012) ###
* Initial release
* Support for simplest configs

