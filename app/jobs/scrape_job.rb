class PostScrapeWorker < ActiveJob::Base
  queue_as :default

  require 'capybara'
  require 'capybara/poltergeist'

  include Sidekiq::Worker
  include Capybara::DSL
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, timeout: 60, js_errors: false)
  end
  Capybara.default_driver = :poltergeist

  def perform(new_catalogue)
    new_catalogue.each do |catalogue_num|
      begin

        #visit page
        visit "http://salefinder.com.au/woolworths-catalogue/weekly-specials-catalogue/#{catalogue_num}/catalogue"
        
        #creating new catalogue
        @catalogue = Catalogue.new
        @catalogue.title = page.all('div#breadcrumb li a')[2].text
        @catalogue.date = page.find('span.sale-dates').text
        @catalogue.catalogue_num = catalogue_num
        @catalogue.shop = page.all('div#breadcrumb li a')[1].text
        @catalogue.shop.slice!(" catalogues")
        if @catalogue.shop == "Woolworths"
          @catalogue.shop_logo = "http://salefinder.com.au/images/retailerlogos/126.jpg"
        else
          @catalogue.shop_logo = "http://salefinder.com.au/images/retailerlogos/148.jpg"
        end
        @catalogue.save

        #start scraping from page 1 and loop to last page
        page_num = 1
        visit "http://salefinder.com.au/woolworths-catalogue/weekly-specials-catalogue/#{catalogue_num}/list?qs=#{page_num}"
        while page.has_css?('span.price')
          #get the price information data on each item on a page
          all('div.item-landscape').each do |item|
            description = item.find('span.item-details h1 a').text
            price_info = item.first('span.price').text if item.first('span.price')
            unit_price = item.first('span.comparative-text').text if item.first('span.comparative-text')
            saving_info = item.find('div.price-options').text if item.find('div.price-options')
            saving_info.slice!(price_info) if price_info
            saving_info.slice!(unit_price) if unit_price
            saving_info if item.find('div.price-options')
            image = item.all('a img')[0][:src]
            Catalogue.find_by(catalogue_num: catalogue_num ).posts.create(description: description, price_info: price_info, unit_price: unit_price, saving_info: saving_info, image: image)
          end
          page_num += 1

          #Capybara reset session
          Capybara.reset_sessions!
          page.driver.reset!

          #visit the next page
          sleep 5
          visit "http://salefinder.com.au/woolworths-catalogue/weekly-specials-catalogue/#{catalogue_num}/list?qs=#{page_num}"
        end
      rescue Capybara::Poltergeist::TimeoutError 
        retry
      end
    end
  end
end