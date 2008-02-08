module Calais
  class Name
    attr_accessor :name, :type, :hash, :locations
    
    TYPES = {
      "cities"                => "City",
      "companies"             => "Company",
      "continents"            => "Continent",
      "countries"             => "Country",
      "industry_terms"        => "IndustryTerm",
      "money_amounts"         => "MoneyAmount",
      "organizations"         => "Organization",
      "people"                => "Person",
      "provinces_and_states"  => "ProvinceOrState",
      "regions"               => "Region",
      "urls"                  => "URL"
    }
    
    def initialize(args={})
      args.each {|k,v| send("#{k}=", v)}
    end
    
    def self.find_in_names(hash, names)
      names.select {|name| name.hash == hash }.first
    end
  end
end
