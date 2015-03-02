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

    #set shop variable as ENV["shop"] as input when calling rake scraper:scrape
    shop = shop_name

    #visit the site
    visit "http://salefinder.com.au/#{shop}-catalogue?qs=1,,0,0,0"

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
        visit "http://salefinder.com.au/#{shop}-catalogue?qs=#{num},,0,0,0"
        #set the location to Melbourne, 3000
        sleep 2
        page.find('a#header-change-region').trigger('click')
        page.find('input#location-search').set("Melbourne, 3000")
        sleep 2
        page.find('div.autocomplete-suggestion').click

        sleep 5
        p page.find('a.pagenumsSelected').text
        
        sleep 5

        #get the price information data on each item on a page
        all('div.item-landscape').each do |item|

          #Create new post
          @post = Post.new
          @post.description = item.find('span.item-details h1 a').text
          @post.price_info = item.first('span.price').text if item.first('span.price')
          @post.unit_price = item.first('span.comparative-text').text if item.first('span.comparative-text')
          price_description = item.find('div.price-options').text if item.find('div.price-options')
          price_description.slice!(@post.price_info) if @post.price_info
          price_description.slice!(@post.unit_price) if @post.unit_price
          @post.saving_info if item.find('div.price-options')
          @post.image = item.all('a img')[0][:src]
          @post.shop_logo = item.all('a img')[1][:src]
          @post.shop = shop

          #save post
          @post.save
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