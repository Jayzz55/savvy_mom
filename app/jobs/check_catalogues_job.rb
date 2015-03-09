class CheckCataloguesJob < ActiveJob::Base
  queue_as :default

  require 'capybara'
  require 'capybara/poltergeist'
  require_relative '../../app/jobs/scrape_catalogues_job.rb'
  require_relative '../../app/jobs/delete_catalogues_job.rb'
  require_relative '../../app/jobs/capybara_quit_job.rb'

  def perform

    #new_catalogues stores result from calling catalogue_gather method
    new_catalogues = catalogue_gather

    #collect current_catalogue data
    current_catalogue = Hash.new(0)
    Catalogue.all.each{|c| current_catalogue[c.id] = c.catalogue_num}

    #scrape new posts from new catalogues
    catalogue_to_add = add_new_catalogue(current_catalogue, new_catalogues)
    ScrapeCataloguesJob.perform_later(catalogue_to_add) if catalogue_to_add.length > 0

    #delete old and duplicate catalogues
    delete_old_duplicate_catalogue(current_catalogue, new_catalogues, catalogue_to_add)  

    #Capybara quit session
    CapybaraQuitJob.perform_later
  end

  private

  def catalogue_gather
    regions = ["Melbourne, 3000", "Sydney, 2000", "Brisbane city, 4000", 'Perth, 6000']
    catalogue_result = []
    session_wait = 7
    regions.each do |region|
      ['Woolworths', 'Coles'].each do |shop|

        #visit the site
        visit "http://salefinder.com.au/#{shop}-catalogue?qs=1,,0,0,0"

        #set the region of the catalogue we want to gather
        set_catalogue_region(region)

        #scrape the catalogue number information
        catalogue_result += scrape_catalogue_number()
        
        sleep session_wait
      end
    end
    return catalogue_result
  end

  def scrape_catalogue_number()
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
    session_wait = 2
    page.find('a#header-change-region').trigger('click')
    page.find('input#location-search').set(region)
    sleep session_wait
    page.find('div.autocomplete-suggestion strong').click
  end

  def add_new_catalogue(current_catalogue, new_catalogues)
    catalogue_addition = []
    new_catalogues.each do |i| 
      catalogue_addition << i unless current_catalogue.has_value?(i)
    end
    return catalogue_addition
  end

  def delete_old_duplicate_catalogue(current_catalogue, new_catalogues, catalogue_to_add)
    catalogue_to_delete = []

    #gather old catalogues and posts
    old_data = current_catalogue.values + catalogue_to_add - new_catalogues

    #gather duplicate catalogues and posts
    duplicate_hash = current_catalogue.values.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
    duplicate_data = duplicate_hash.select{|k,v| v>1}.keys

    #delete old and duplicate catalogues
    catalogue_to_delete = old_data + duplicate_data
    DeleteCataloguesJob.perform_later(catalogue_to_delete) if catalogue_to_delete.length > 0
  end
end