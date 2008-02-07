module Calais
  class Relationship
    attr_accessor :type, :hash, :metadata, :locations
    
    def initialize(args={})
      args.each {|k,v| send("#{k}=", v)}
    end
  end
end
