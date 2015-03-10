require 'capybara'
require 'capybara/poltergeist'

class CapybaraQuitJob < ActiveJob::Base
  include Capybara::DSL
  queue_as :default

  def perform
    visit "http://salefinder.com.au/"
    page.driver.quit
  end
end