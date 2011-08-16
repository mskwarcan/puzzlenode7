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
  
  # Conversion Rates
  eur_to_aud = rates.detect {|rate| rate["from"] == "EUR" and rate["to"] == "AUD"}
  aud_to_cad = rates.detect {|rate| rate["from"] == "AUD" and rate["to"] == "CAD"}
  cad_to_usd = rates.detect {|rate| rate["from"] == "CAD" and rate["to"] == "USD"}
  
  eur_rate = BigDecimal.new(eur_to_aud["conversion"])
  aud_rate = BigDecimal.new(aud_to_cad["conversion"])
  cad_rate = BigDecimal.new(cad_to_usd["conversion"])
  
  
  #Default data
  sku = "DM1182"
  
  rows = []
  FasterCSV.foreach("public/TRANS.csv") do |row|
     if row[1] == sku
       rows << row
     end
   end
   
   total = BigDecimal.new('0')
 
   rows.each do |row|
     amount = row[2].split(' ')
     value = BigDecimal.new(amount[0])
     type = amount[1]
     
     if type == "USD"
       total += value
     else
       if type == "EUR"
         #convert EUR to AUD
         value = BigDecimal.new(sprintf("%.2f", value * eur_rate * aud_rate * cad_rate))
         total += value
       end
     
       if type == "AUD"
         #convert AUD to CAD
         value = BigDecimal.new(sprintf("%.2f", value * aud_rate * cad_rate))
         total += value
       end
     
       if type == "CAD"
         #convert CAD to USD
         value = BigDecimal.new(sprintf("%.2f", value * cad_rate))
         total += value
       end
     end
   end
   
   @total = total
   
   erb :total
end
