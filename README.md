NagiosCheck
============

Description
-----------

NagiosCheck is a simple and efficient tool for building custom probes for the
Nagios monitoring system. It alleviates the pain of parsing command line
options, writing and formatting the check results according to the Nagios 
plugin API.

Installation
------------
 
``` bash
gem install nagios_check
```

Features
--------

* Provide a simple to use DSL for building your own probes.
* Parse command line options.
* Report status data to Nagios (handles exceptions as UNKNOWN status).
* Provide a Nagios like range description format for the WARNING and CRITICAL states.
* Provide a simple timeout functionality to be more Nagios friendly.
* Report performance data to Nagios.

Usage and documentation
-----------------------

NagiosCheck is a module. To use it simply include it in a class and declare
how the check should behave:

``` ruby
require "nagios_check"

class SimpleCheck
  include NagiosCheck

  on "-H HOST", :required, &store(:host)
  on "-P PORT",            &store(:port, default: 8080)

  enable_warning
  enable_critical
  enable_timeout

  def check
    time = do_some_check(options.host, options.port)
    store_value :duration, time
  end
end

SimpleCheck.new.run
```

The command can then be used by Nagios:

``` bash
  ruby simple_check.rb -H my_host -P my_port -w 4 -c 8 -t 10
```
  

License
-------
Released under the MIT License.  See the [MIT-LICENSE][license] file for further details.

[license]: https://github.com/dbroeglin/nagios_check/blob/master/MIT-LICENSE 

Copyright 2011 Dominique Broeglin 

