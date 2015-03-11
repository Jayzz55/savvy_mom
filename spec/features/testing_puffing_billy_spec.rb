require 'rails_helper'
require 'spec_helper'
require 'billy/rspec'

feature 'testing puffing billy', js: true do
  scenario 'testing puffing billy' do
    # proxy.stub('http://example.com/text/').and_return(:text => 'Foobar')
    # visit 'http://example.com/text/'
    # expect(page).to have_content("Foobar")
    require './app/jobs/check_catalogues_job.rb'
    proxy.stub("http://salefinder.com.au/Coles-catalogue/").and_return(:text => 'Foobar')
    proxy.stub("http://salefinder.com.au/Woolworths-catalogue/").and_return(:text => 'Foobar')
    # # CheckCataloguesJob.perform_later
    # CheckCataloguesJob.new.scrape_published_catalogue_nums
    visit "http://salefinder.com.au/Coles-catalogue/"
    expect(page).to have_content("Foobar")

  end
end