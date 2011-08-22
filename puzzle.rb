require 'rubygems'
require 'bundler'
require 'active_support/core_ext'
Bundler.setup

require 'sinatra'

get "/" do
  
  #constant
  tax_rate = 1.0411416
  
  #convert .json into a hash
  file = File.open("public/vacation_rentals.json")
  json = file.readlines.to_s
  data = ActiveSupport::JSON.decode(json)
  
  #grab start and end date
  file = File.open("public/input.txt")
  text = file.readlines.to_s
  dates = text.partition(/ - /)
  start_date = Time.parse(dates[0]).to_date
  end_date = Time.parse(dates[2]).to_date
  
  resorts = []
  
  data.each do |resort|
    days = (end_date - start_date).to_i
    rate = 0
    cleaning_fee = 0
    
    name = resort["name"]
    cleaning_fee = resort["cleaning fee"].nil? ? 0 : resort["cleaning fee"].delete("$").to_f
    rate = resort["rate"].nil? ? 0 : resort["rate"].delete("$").to_f
    
    if resort["seasons"]
      season_one = resort["seasons"][0]["one"]
      season_two = resort["seasons"][1]["two"]
    end
    
    if rate != 0
      #get price if no seasons
      price = sprintf("%.2f", ((days * rate) + cleaning_fee) * tax_rate)
    else
      #season one data
      season_one_rate = season_one["rate"].delete("$").to_f
      
      #figure out if the range is within the same year
      start_month = season_one["start"].partition(/-/)[0]
      end_month = season_one["end"].partition(/-/)[0]
      if start_month.to_i > end_month.to_i
        end_date_year = "2012-"
      else 
        end_date_year = "2011-"
      end
      
      season_one_start = Time.parse("2011-"+season_one["start"]).to_date
      season_one_end = Time.parse(end_date_year+season_one["end"]).to_date
      season_one_range = season_one_start..season_one_end
      
      #season two data
      season_two_rate = season_two["rate"].delete("$").to_f
      
      #figure out if the range is within the same year
      start_month = season_two["start"].partition(/-/)[0]
      end_month = season_two["end"].partition(/-/)[0]
      if start_month.to_i > end_month.to_i
        end_date_year = "2012-"
      else 
        end_date_year = "2011-"
      end
      
      season_two_start = Time.parse("2011-"+season_two["start"]).to_date
      season_two_end = Time.parse(end_date_year+season_two["end"]).to_date
      
      
      if season_one_range === start_date
        if season_one_end < end_date
          season_one_days = (season_one_end - start_date).to_i + 1
        else
          season_one_days = days
          season_two_price = 0
        end
        season_one_price = (season_one_days * season_one_rate)
        
        days = days - season_one_days
      end
      
      if days != 0
        season_two_price = (days * season_two_rate)
      end
      
      price = sprintf("%.2f", (season_two_price + (season_one_price.nil? ? 0 : season_one_price) + cleaning_fee) * tax_rate)
      
    end  
    
    resorts << [name,price]
  end
  
  @total = resorts
  
  erb :total
end