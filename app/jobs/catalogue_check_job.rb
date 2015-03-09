class CatalogueCheckWorker < ActiveJob::Base
  queue_as :default

  require 'capybara'
  require 'capybara/poltergeist'
  require_relative '../../app/jobs/scrape_job.rb'
  require_relative '../../app/jobs/delete_job.rb'

  include Capybara::DSL
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, timeout: 60, js_errors: false)
  end
  Capybara.default_driver = :poltergeist

  def perform

    #setting the initial variable
    current_catalogue = Hash.new(0)
    compare_catalogue_array = []
    new_catalogue = []
    catalogue_delete = []
    regions = ["Melbourne, 3000", "Sydney, 2000", "Brisbane city, 4000", 'Perth, 6000']

    #collect current_catalogue data
    Catalogue.all.each{|c| current_catalogue[c.id] = c.catalogue_num}

    #collect compare_catalogue_array data
    compare_catalogue_array = catalogue_gather(regions)

    #scrape new posts from new catalogue
    compare_catalogue_array.each do |i| 
      new_catalogue << i unless current_catalogue.has_value?(i)
    end
    PostScrapeWorker.perform_later(new_catalogue)


    #gather old catalogues and posts
    old_data = current_catalogue.values + new_catalogue - compare_catalogue_array

    #gather duplicate catalogues and posts
    current_catalogue_array =  current_catalogue.values
    duplicate_hash = current_catalogue_array.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
    duplicate_data = duplicate_hash.select{|k,v| v>1}.keys

    #delete old and duplicate catalogues
    catalogue_delete = old_data + duplicate_data
    DeleteWorker.perform_later(catalogue_delete)
  end

  private

  def catalogue_gather(regions)
    array_result = []
    regions.each do |region|
      ['Woolworths', 'Coles'].each do |shop|

        #visit the site
        visit "http://salefinder.com.au/#{shop}-catalogue?qs=1,,0,0,0"

        #set the region of the catalogue we want to gather
        page.find('a#header-change-region').trigger('click')
        page.find('input#location-search').set(region)
        page.find('div.autocomplete-suggestion strong').click

        #scrape the catalogue number information
        item_url = page.find('a.catalogue-image img')[:src]
        start_count = "http://salefinder.com.au/images/featureimage/iphone/".length
        end_count = item_url.length - (".jpg".length) - 1
        array_result <<  catalogue_num = item_url.slice!(start_count..end_count)

        sleep 5
      end
    end
    return array_result
  end
end