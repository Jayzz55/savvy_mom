require 'capybara'
require 'capybara/poltergeist'
require './app/jobs/scrape_catalogues_job.rb'
require './app/jobs/delete_catalogues_job.rb'
require './app/jobs/capybara_quit_job.rb'

class CheckCataloguesJob < ActiveJob::Base
  include Capybara::DSL
  queue_as :default

  def perform

    published_catalogue_nums = scrape_published_catalogue_nums
    
    catalogue_to_be_added = catalogue_to_add(published_catalogue_nums)
    ScrapeCataloguesJob.perform_later(catalogue_to_be_added) if catalogue_to_be_added.any?

    catalogue_to_be_deleted = catalogue_to_delete(published_catalogue_nums, catalogue_to_be_added)
    DeleteCataloguesJob.perform_later(catalogue_to_be_deleted) if catalogue_to_be_deleted.any?  

    CapybaraQuitJob.perform_later
  end

  def catalogue_to_add(published_catalogue_nums)
    known_catalogue_nums = Catalogue.pluck(:catalogue_num) 
    return published_catalogue_nums - known_catalogue_nums
  end

  def scrape_published_catalogue_nums
    # regions = ["Melbourne, 3000", "Sydney, 2000", "Brisbane city, 4000", 'Perth, 6000']
    regions = ["Melbourne, 3000"]
    published_catalogue_nums = []
    session_wait = 3
    regions.each do |region|
      
      visit "http://salefinder.com.au/Woolworths-catalogue?qs=1,,0,0,0"
      set_catalogue_region(region)

      sleep session_wait

      visit "http://salefinder.com.au/Coles-catalogue?qs=1,,0,0,0"
      published_catalogue_nums += scrape_catalogue_number

      sleep session_wait

      visit "http://salefinder.com.au/Woolworths-catalogue?qs=1,,0,0,0"
      published_catalogue_nums += scrape_catalogue_number
      
    end
    return published_catalogue_nums
  end

  def scrape_catalogue_number
    catalogue_number = []
    page.all('a.catalogue-image img').each do |catalogue|
      item_url = catalogue[:src]
      start_count = "http://salefinder.com.au/images/featureimage/iphone/".length
      end_count = item_url.length - (".jpg".length) - 1
      catalogue_number << item_url.slice!(start_count..end_count)
    end
    return catalogue_number
  end

  def set_catalogue_region(region)
    # session_wait = 5
    # page.find('a#header-change-region').trigger('click')
    # sleep 10
    # page.execute_script('$("a#header-change-region").trigger("click")')
    # page.find('input#location-search').set(region)
    # sleep session_wait
    # page.find('div.autocomplete-suggestion strong').click

    page.execute_script("$.cookie('postcodeId', 5188)")
    page.execute_script("$.cookie('regionName', 'MELBOURNE, 3000')")

  end

  def catalogue_to_delete(published_catalogue_nums, catalogue_to_add)
    catalogue_to_delete = []

    current_catalogue = {}
    Catalogue.all.each{|c| current_catalogue[c.id] = c.catalogue_num}

    #gather old catalogues and posts
    old_data = current_catalogue.values + catalogue_to_add - published_catalogue_nums

    #gather duplicate catalogues and posts
    duplicate_hash = current_catalogue.values.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
    duplicate_data = duplicate_hash.select{|k,v| v>1}.keys

    #delete old and duplicate catalogues
    return catalogue_to_delete = old_data + duplicate_data
  end
end