class HardWorker
  require 'capybara'
  require 'capybara/poltergeist'

  include Sidekiq::Worker
  include Capybara::DSL
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, timeout: 60, js_errors: false)
  end
  Capybara.default_driver = :poltergeist

  # perform scraping job through capybara/poltergeist
  def perform(shop_name)

    #visit the site
    visit "http://salefinder.com.au/#{shop_name}-catalogue?qs=1,,0,0,0"

    #set the location to Melbourne, 3000
    page.find('a#header-change-region').trigger('click')
    page.find('input#location-search').set("Melbourne, 3000")
    page.find('div.autocomplete-suggestion').click

    #getting total product count
    product_count = page.find('span#product-count').text
    product_count.slice!("Showing 0-12 of ")
    product_count.slice!(" products for Woolworths")
    product_count = product_count.to_i

    #setting the max_page, first_page, and intermediate_page
    max_page = (product_count.to_f/12).ceil
    first_page = 1
    page_number = 1
    num_rescue = 0

    begin
      #loop from first_page to max_page
      (page_number..max_page).each do |num|

        #Capybara reset session
        Capybara.reset_sessions!
        page.driver.reset!
        page_number = num

        #setting the location
        visit "http://salefinder.com.au/#{shop_name}-catalogue?qs=#{num},,0,0,0"
        #set the location to Melbourne, 3000
        sleep 2
        page.find('a#header-change-region').trigger('click')
        page.find('input#location-search').set("Melbourne, 3000")
        sleep 2
        page.find('div.autocomplete-suggestion').click

        sleep 5
        p page.find('a.pagenumsSelected').text
        
        sleep 5

        # Create new catalogue
        all('div.retailer-catalogue').each do |item|
          @catalogue = Catalogue.new
          @catalogue.url = "http://salefinder.com.au" + item.find('a.catalogue-image')[:href]
          @catalogue.title = item.find('div.catalogue-name').text
          @catalogue.date = item.find('div.catalogue-date').text

          #setting up the catalogue_num
          catalogue = "http://salefinder.com.au" + @catalogue.url
          start_count = "http://salefinder.com.au/woolworths-catalogue/weekly-specials-catalogue-vic/".length
          end_count = catalogue.length - ("/catalogue".length) -1
          @catalogue.catalogue_num = catalogue.slice(start_count..end_count)

          @catalogue.shop = shop_name
          #!!This is temporarily fixed to woolworth's logo!!
          if @catalogue.shop == "Woolworths"
            @catalogue.shop_logo = "http://salefinder.com.au/images/retailerlogos/126.jpg"
          else
            @catalogue.shop_logo = "http://salefinder.com.au/images/retailerlogos/148.jpg"
          end
          @catalogue.save
        end

        #get the price information data on each item on a page
        all('div.item-landscape').each do |item|

          item_catalogue = item.all('a img')[0][:src]
          start1 = "http://salefinder.com.au/images/thumb/".length
          end1 = item_catalogue.length - ("331.jpg".length) -1
          p item_catalogue_num = item_catalogue.slice(start1..end1)
          p Catalogue.all

          #Create new post
          description = item.find('span.item-details h1 a').text
          price_info = item.first('span.price').text if item.first('span.price')
          unit_price = item.first('span.comparative-text').text if item.first('span.comparative-text')
          saving_info = item.find('div.price-options').text if item.find('div.price-options')
          saving_info.slice!(price_info) if price_info
          saving_info.slice!(unit_price) if unit_price
          saving_info if item.find('div.price-options')
          image = item.all('a img')[0][:src]
          Catalogue.find_by(catalogue_num: item_catalogue_num ).posts.create(description: description, price_info: price_info, unit_price: unit_price, saving_info: saving_info, image: image)
      
        end
        sleep 5 
        p "-------------------- next page --------------"

      end

    rescue Capybara::Poltergeist::TimeoutError 
      p "!!!!!!!!!!!!!!!------rescue is working on page #{page_number}-----!!!!!!!!!!!!!!!!!!!!!!"
      num_rescue = num_rescue + 1
      retry

    end

      p "Number of rescue = #{num_rescue} !!!!!!!!!!!!!"


    page.driver.quit
  end
end