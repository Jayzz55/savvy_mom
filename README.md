Savvy Mom
========================

A webscrapping app that scrape specials information from Coles and Woolworths and present these to shoppers to quickly check what's the worthy special this week. 

This is created as part of final project for Bloc.io and also a personal side project.
[Check out Savvy Mom](http://savvy-mom.herokuapp.com)

Noteworthy Technologies:
-------------------------------

* [Poltergeist](https://github.com/teampoltergeist/poltergeist). A PhantomJS driver for Capybara is used as the main engine to do the webscraping. This method is used instead of [Nokogiri](https://github.com/sparklemotion/nokogiri) or [Mechanize](https://github.com/sparklemotion/mechanize), because of the javascript interaction of the site this app is scraping.
* [Puffing Billy](https://github.com/oesmith/puffing-billy) for testing the webscraping jobs. This uses the local caches to act like [VCR](https://github.com/vcr/vcr) that record test suite's HTTP interactions and replay them during future test runs for fast, deterministic, accurate tests.
* [Pry Bye-bug](https://github.com/deivid-rodriguez/pry-byebug) for debugging
* [Rspec](https://github.com/rspec/rspec-rails) for testing
* [Capybara](https://github.com/jnicklas/capybara) for integration testing and also tool for webscraping
* [will_paginate](https://github.com/mislav/will_paginate) for pages pagination
* [Bootstrap](http://getbootstrap.com/) responsive framework

Future plans for verions 2.0:
-----------------------------

* include a search box using elastic search
* redesign the site for a more responsive and friendler mobile site
* implement a front end framework such as Backbone or Angular JS


Contribute:
--------------

- Found a bug? Report it on GitHub and include a code sample.

- Check it out [Check out Savvy Mom](http://savvy-mom.herokuapp.com) and email [me](jayzzwijono@yahoo.com) for any input feedback to the app.




