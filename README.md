# Senor Armando - Goliath Helpers

In Planet of the Apes, Señor Armando is the owner of a circus, a human friend of Cornelius and Zira, and caregiver for Ceasar, teaching him human knowledge and introducing him to human habits.

On the Planet of the APIs, Señor Armando is a collection of helper methods that introduce human habits to your goliath app.

Both have an enthusiastic appreciation for rich Corinthian leather.

![Señor Armando photo](http://github.com/infochimps-labs/senor_armando/raw/master/senor_armando.jpeg)

## Setup

* run `armando_gemfile_jail`; this will run bundler install but cache the results locally for much quickness. **You MUST run it at least once explicitly**.

That should be it!
  
## Overview


## Code Organization

## Logging to Statsd

Start a graphite and statsd server:

```bash
    python2.6 /usr/local/share/graphite/bin/carbon-cache.py start & sleep 1 ;
    python2.6 /usr/local/share/graphite/bin/run-graphite-devel-server.py /usr/local/share/graphite & sleep 2 ;
    node ~/ics/repos/statsd/stats.js /etc/graphite/statsd_config.js &
```

## PassthruProxy

## Colophon

Built with
* [Goliath](http://goliath.io)
* [Gorillib](http://github.com/infochimps-labs/gorillib)
* the [Señor Armando photo](http://www.flickr.com/photos/jonknutson/2176806164/sizes/o/in/photostream/) is courtesy Flickr user [jonknutson](http://www.flickr.com/photos/jonknutson).
