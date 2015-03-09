class CapybaraQuitJob < ActiveJob::Base
  queue_as :default

  require 'capybara'
  require 'capybara/poltergeist'

  include Capybara::DSL
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, timeout: 60, js_errors: false)
  end
  Capybara.default_driver = :poltergeist

  def perform
    visit "http://salefinder.com.au/"
    page.driver.quit
  end
end