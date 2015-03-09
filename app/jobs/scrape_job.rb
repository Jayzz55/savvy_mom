class PostScrapeWorker < ActiveJob::Base
  queue_as :default

  require 'capybara'
  require 'capybara/poltergeist'
  
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
          @catalogue.area = @catalogue.title["Weekly Specials Catalogue ".length .. @catalogue.title.length] + " METRO"
        else
          @catalogue.shop_logo = "http://salefinder.com.au/images/retailerlogos/148.jpg"
          @catalogue.area = @catalogue.title["Coles Catalogue ".length .. @catalogue.title.length]
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
            image = item.all('a img')[0][:src]
            #call the private saving method and save the result array into 'savings'
            savings = saving(price_info, saving_info)

            #create the post under the catalogue it's associated with
            Catalogue.find_by(catalogue_num: catalogue_num ).posts.create(description: description, price_info: price_info, unit_price: unit_price, saving_info: saving_info, image: image, saving: savings[0], saving_percentage: savings[1])
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

  private

  #setting a method that return an array consist of savings information, and savings percentage.
  def saving(price_info, saving_info)
    #setting the regexp match condition
    save_exist = /\Save/
    was_exist = /\Sas/
    price_exist = /\$/
    save_decimal = /\Save\s[\w\s]*\$([0-9]*\.[0-9]*)/
    was_decimal = /\Sas\s[\w\s]*\$([0-9]*\.[0-9]*)/
    price_decimal = /([0-9]*\.[0-9]*)/
    for_exist = /\wor/
    half_price_exist = /1\/2/

    #setting the local savings_array to store the result
    savings_array = []

    #setting the local variable 'price' to store the value of discounted price
    if !price_info
      price = ''
    elsif price_info.match for_exist
      price = ''
    elsif price_info.match price_exist
      price_value = price_info.match price_decimal
      price = price_value[1] 
    else
      price =''
    end 

    #setting the local variable 'savings' to store how much money we save
    #setting the local variable 'savings_percentage' to store the percentage of savings we get
    if !saving_info
      savings = ''
      savings_percentage = ''
    elsif saving_info.match save_exist
      save_value = saving_info.match save_decimal
      savings = save_value[1]
      if saving_info.match half_price_exist
        savings_percentage = '50%'
      elsif saving_info.match was_exist
        was_value = saving_info.match was_decimal
        savings_percentage = "#{(savings.to_f/was_value[1].to_f*100).round(0)}%"
      else
        savings_percentage = ''
      end
    elsif saving_info.match was_exist
      was_value = saving_info.match was_decimal
      savings = "#{(was_value[1].to_f - price.to_f).round(2)}"
      if savings.to_f > 0.0
        savings_percentage = "#{(savings.to_f/was_value[1].to_f*100).round(0)}%"
      else
        savings_percentage = ''
      end
    elsif saving_info.match price_exist
      price_value = saving_info.match price_decimal
      savings = "#{(price_value[1].to_f - price.to_f).round(2)}"
      if savings.to_f > 0.0
        savings_percentage = "#{(savings.to_f/price_value[1].to_f*100).round(0)}%"
      else
        savings_percentage = ''
      end
    else
      savings = ''
      savings_percentage = ''
    end

    #This is to fixed misinformation captured, and set savings to ''
    savings = '' if savings.to_f < 0.0

    return savings_array = [savings, savings_percentage]
  end
end