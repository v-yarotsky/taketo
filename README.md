Take Me To
==========

[![Build Status](https://secure.travis-ci.org/v-yarotsky/taketo.png)](http://travis-ci.org/v-yarotsky/taketo)

A tiny helper utility to make access to servers eaiser for different projects and environments.

Usage:
------

puts a config into ```~/.taketo.rc.rb```:

```ruby
  project :my_project do
    environment :staging do
      server :s1 do
        host "1.2.3.4"
        port 10001
        user "app"
        localtion "/var/app"
      end
    end
  end
```

Then execute:

```taketo my_project staging s1 [command to execute, bash by default]```

To-Do:
------

* Add support for defaults
* Add support for generating shortcuts

The Changelog:
--------------

### v0.0.1 (13.06.2012) ###
* Initial release
* Support for simplest configs

