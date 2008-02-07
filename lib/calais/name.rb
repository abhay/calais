module Calais
  class Name
    attr_accessor :name, :type, :hash, :locations
    
    def initialize(args={})
      args.each {|k,v| send("#{k}=", v)}
    end
    
    def self.find_in_names(hash, names)
      names.select {|name| name.hash == hash }.first
    end
  end
end
