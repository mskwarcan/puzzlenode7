require 'rubygems'
require 'fastercsv'
require 'active_support/core_ext'
require 'bundler'
Bundler.setup

require 'sinatra'

get "/" do
  
  #Read XML
  xml = File.read("public/rates.xml")
  #XML to Hash
  hash = Hash.from_xml(xml)
  rates = hash["rates"]["rate"]
  
  #Default data
  sku = "DM1182"
  
  rows = []
  FasterCSV.foreach("public/TRANS.csv") do |row|
     if row[1] == sku
       rows << row
     end
   end
   
   total = 0
 
   rows.each do |row|
     amount = row[2].split(' ')
     value = amount[0].to_f
     type = amount[1]
     
     if type == "USD"
       total += value
     else
       if type == "EUR"
         rate = rates.detect {|rate| rate["from"] == "EUR" and rate["to"] == "AUD"}
         #convert EUR to AUD
         value = value * rate["conversion"].to_f
         type = "AUD"
       end
     
       if type == "AUD"
         rate = rates.detect {|rate| rate["from"] == "AUD" and rate["to"] == "CAD"}
         #convert AUD to CAD
         value = value * rate["conversion"].to_f
         type = "CAD"
       end
     
       if type == "CAD"
         rate = rates.detect {|rate| rate["from"] == "CAD" and rate["to"] == "USD"}
         #convert CAD to USD
         value = round(value * rate["conversion"].to_f)
         type = "USD"
         
         total += value
       end
     end
   end
   
   @total = total
   
   erb :total
end

def round(value)
  value = value*100
  
  round = sprintf("%.1f", value)
  if round[-1, 1] == "5"
    if (value.to_i + 1).odd?
      value = (value.to_i).to_f
    else
      value = (value.to_i+1).to_f
    end
  else
     value =sprintf("%.0f", value).to_f
  end
  value = value/100
end
