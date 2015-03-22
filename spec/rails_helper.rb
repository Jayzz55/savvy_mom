# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require "capybara/poltergeist"
require 'billy/rspec'
# Add additional requires below this line. Rails is not loaded until this point!
Capybara.javascript_driver = :poltergeist
# Capybara.javascript_driver = :poltergeist_billy

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Make Factory Girl's methods avilable
    config.include FactoryGirl::Syntax::Methods
end

Billy.configure do |c|
  c.cache = true
  c.cache_request_headers = false
  c.ignore_params = ["http://www.google-analytics.com/__utm.gif",
                     "https://r.twimg.com/jot",
                     "http://p.twitter.com/t.gif",
                     "http://p.twitter.com/f.gif",
                     "http://www.facebook.com/plugins/like.php",
                     "https://www.facebook.com/dialog/oauth",
                     "http://cdn.api.twitter.com/1/urls/count.json",
                     "https://log.pinterest.com/",
                     'https://widgets.pinterest.com/',
                     'https://www.facebook.com/',
                     'https://www.facebook.com/connect/ping']
                     # 'http://salefinder.com.au/ajax/locationsearch']
  # c.path_blacklist = []
  c.persist_cache = true
  c.ignore_cache_port = true # defaults to true
  c.non_successful_cache_disabled = false
  c.non_successful_error_level = :warn
  c.non_whitelisted_requests_disabled =true
  c.cache_path = 'spec/req_cache/'
  # Stripe uses jsonp, which changes its callback param based on the current time
  # That means we'd never hit the cache, so this makes it ignore the param that changes
  c.dynamic_jsonp = true
  c.dynamic_jsonp_keys = ['callback',"_"]
  c.whitelist = ['test.host', 'localhost', '127.0.0.1']
  c.proxied_request_connect_timeout = 20
  c.proxied_request_inactivity_timeout = 20
end

#puffing-billy: CACHE KEY for 'http://salefinder.com.au/ajax/locationsearch?callback=jQuery18202362879642751068_1426590113652&query=Melbourne%2C+3000&_=1426590116129' is 'get_salefinder.com.au_2d6206cd9f5712129e1af22dae4add994d5e5494'
# RuntimeError (puffing-billy: Connection to http://salefinder.com.au/ajax/locationsearch?callback=jQuery18202362879642751068_1426590113652&query=Melbourne%2C+3000&_=1426590116129 not cached and new http connections are disabled):
