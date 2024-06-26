NagiosCheck
============

[![Gem Version](https://badge.fury.io/rb/nagios_check.svg)](https://badge.fury.io/rb/nagios_check)

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

NagiosCheck is a module. To use it, simply include it in a class and declare
how the check should behave:

``` ruby
require "nagios_check"

class SimpleCheck
  include NagiosCheck

  on "--host HOST", "-H HOST", :mandatory
  on "--port PORT", "-P PORT", Integer, default: 8080

  enable_warning
  enable_critical
  enable_timeout

  def check
    time = do_some_check(options.host, options.port)
    
    store_value :duration, time
    store_message "The check took #{time} seconds"
  end
end

SimpleCheck.new.run
```

The command can then be used by Nagios:

``` bash
  ruby simple_check.rb -H my_host -P my_port -w 4 -c 8 -t 10
```

If the number passed to `store_value` is between 0 and 4 inclusive the result is OK.  If it is greater than 4 and less than 8 inclusive the result is WARNING. If it is greater than 8 the result is CRITICAL. See [Nagios Developer Guidelines][nagios-dev] for more details on how the arguments of `-w` and `-c` are interpreted.

If `store_value` is called multiple times, the value from the first call is used to determine the result. Multiple `store_value` calls can be used to include additional performance data in the output.

If the check method lasts more than 10 seconds, it times out and the returned value is UNKNOWN.

Calling `store_message` is optional. However, the text passed to `store_message` will be displayed next to the check status in the Nagios web interface and can be included in notification mails to provide some context in a human readable format. 

If the only metric we are interested is the time it takes to execute the check, an alternative shorter way of writting the above would be:

```ruby
def check
  time(value_name: 'duration') do
    do_some_check(options.host, options.port)
  end
end
```

This check will execute `do_some_check` measure the time it takes to execute it and return both status and performance data labeled `duration`. 

Writing Tests for Checks
------------------------

Checks can be integration tested by calling the `perform` method
instead of the `run` method. `perform` takes an array of command line
arguments and returns a `NagiosCheck::Result` object, which supports
`ok?`, `warning?` and `critical?` methods to query the status and
exposes the stored values:

```ruby
RSpec.describe SomeCheck do
  it 'is ok by default' do
    result = SomeCheck.new.perform(%w(-w 5 -c 10))

    expect(result).to be_ok
  end

  it 'results in warning if there are more thn 5 uploads purchases' do
    # Setup environment such that the check detects problems
    # ...

    result = SomeCheck.new.perform(%w(-w 5 -c 10))

    expect(result).to be_warning
    expect(result.values[:some_stored_value]).to eq(6)
  end
end

```

License
-------
Released under the MIT License.  See the [MIT-LICENSE][license] file for further details.

[license]: https://github.com/dbroeglin/nagios_check/blob/master/MIT-LICENSE 
[nagios-dev]: http://nagiosplug.sourceforge.net/developer-guidelines.html

Copyright 2011-2016 Dominique Broeglin 

