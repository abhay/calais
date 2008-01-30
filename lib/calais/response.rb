module Calais
  class Response
    attr_reader :rdf, :names, :relationships, :error
    
    def initialize(raw, error=nil)
      @error = error
      @names = []
      @relationships = []

      parse_rdf(raw)
      parse_names
      parse_relationships
    end
    
    private
      def parse_rdf(raw)
        @rdf = CGI::unescapeHTML Hpricot.XML(raw).at("/string").inner_html
        @hpricot = Hpricot.XML(@rdf)
        @error = Hpricot.XML(response).at("/Error/Exception").inner_html rescue @error
      end
      
      def parse_names
        @names = @hpricot.root.search("rdf:Description//c:name//..").map do |ele|
          Calais::Response::Name.new(
            :name => ele.at("c:name").inner_html,
            :hash => ele.attributes["rdf:about"].split('/').last,
            :type => ele.at("rdf:type").attributes["rdf:resource"].split('/').last
          )
        end unless @error
      end
      
      def parse_relationships
        doc = @hpricot.dup
        doc.search("rdf:Description//c:docId//..").remove
        doc.search("rdf:Description//c:document//..").remove
        doc.search("rdf:Description//c:name//..").remove
        
        @relationships = doc.root.search("rdf:Description").map do |ele|
          relationship = ele.at("rdf:type")
          actor = relationship.next_sibling
          metadata = actor.next_sibling.attributes["rdf:resource"] ? nil : actor.next_sibling.inner_html.strip
          target = metadata ? actor.next_sibling.next_sibling : actor.next_sibling
          
          Calais::Response::Relationship.new(
            :type => relationship.attributes["rdf:resource"].split('/').last,
            :actor => Name.find_in_names(actor.attributes["rdf:resource"].split('/').last, @names),
            :target => Name.find_in_names(target.attributes["rdf:resource"].split('/').last, @names),
            :metadata => metadata
          )
        end
      end
    
    class Name
      attr_accessor :name, :type, :hash
      
      def initialize(args={})
        args.each {|k,v| send("#{k}=", v)}
      end
      
      def self.find_in_names(hash, names)
        names.select {|name| name.hash == hash }.first
      end
    end
    
    class Relationship
      attr_accessor :type, :actor, :target, :metadata
      
      def initialize(args={})
        args.each {|k,v| send("#{k}=", v)}
      end
    end
  end
end