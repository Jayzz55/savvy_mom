class CapybaraQuitJob < ActiveJob::Base
  queue_as :default

  require 'capybara'
  require 'capybara/poltergeist'

  def perform
    visit "http://salefinder.com.au/"
    page.driver.quit
  end
end