# Goliath Skeleton

A collection of base endpoints and helper methods that capture common API patterns

## Setup

* run ./config/bootstrap.rb; this will run bundler install but cache the results locally for much quickness. You MUST run ./config/bootstrap (or bundle install) at least once explicitly.

* optionally, start a graphite and statsd server:

```bash
    python2.6 /usr/local/share/graphite/bin/carbon-cache.py start & sleep 1 ;
    python2.6 /usr/local/share/graphite/bin/run-graphite-devel-server.py /usr/local/share/graphite & sleep 2 ;
    node ~/ics/repos/statsd/stats.js /etc/graphite/statsd_config.js &
```

That should be it!
  
## Overview


## Code Organization

## Logging to Statsd



## PassthruProxy


