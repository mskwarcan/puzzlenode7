require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'

get "/" do
  def get_conversion_rates
    xml = File.read("public/rates.xml")
    
    rates = Hash.from_xml(xml)
    
    return rates
  end
  
  def get_amount(sku)
    rows = []
    FasterCSV.foreach("public/TRANS.csv") do |row|
       if row[1] == sku
         rows << row
       end
     end
     
     rates = get_conversion_rates()
     
     rows.each do |row|
       amount = row[3].split(' ')
       value = amount[0]
       type = amount[1]
       
       if type == "USD"
         total += value
       else
         if type == "EUR"
           rate = rates.detect {|rate| rate["from"] == "EUR" and rate["to"] == "AUD"}
           #convert EUR to AUD
           value = value * 
           type = "AUD"
         end
         
         if type == "AUD"
           rates.detect {|rate| rate["from"] == "AUD" and rate["to"] == "CAD"}
           #convert AUD to CAD
           type = "CAD"
         end
         
         if type == "CAD"
           rates.detect {|rate| rate["from"] == "CAD" and rate["to"] == "USD"}
           #convert CAD to USD
           type = "USD"
         end
       end
     end
     
     return total
  end
end