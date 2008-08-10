module Calais
  class Response
    attr_reader :rdf, :names, :relationships, :error
    
    def initialize(raw, error=nil)
      @error = error
      @names = []
      @relationships = []

      parse_raw(raw)
      return if @error
      
      parse_names
      parse_relationships
    end
    
    Name::TYPES.each_pair do |method_name, type|
      define_method method_name.to_sym do
        @names.map {|name| name if name.type == type }.compact
      end
    end
    
    private
      def parse_raw(raw)
        @libxml = XML::Parser.string(XML::Parser.string(raw).parse.root.child.content).parse
        @rdf = @libxml.to_s
        @error = @libxml.find("/Error/Exception").first.content rescue @error
      end
      
      def parse_names
        @names = @libxml.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '/em/e/')]/..").map do |n|
          name = n.find_first("c:name").content
          type = n.find_first("rdf:type").properties["resource"].split('/').last
          hash = n.properties["about"].split("/").last
          
		  locations = []
          locations = @libxml.root.find("rdf:Description/c:subject[contains(@rdf:resource, '#{hash}')]/..").each do |n2|
            if start = n2.find_first("c:offset")
              start = start.content.to_i
			  Range.new(start, start+n2.find_first("c:length").content.to_i)
			end
          end
          
          Name.new(
            :name => name,
            :hash => hash,
            :type => type,
            :locations => locations
          )
        end
      end
      
      def parse_relationships
        @libxml.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '/em/r')]/..").each do |n|
          hash = n.properties["about"].split("/").last
          type = n.find_first("rdf:type").properties["resource"].split('/').last
          
          metadata = {}
          
          n.to_a.each do |n2|
            next if n2.name == "type" or n2.comment?
            resource = n2.properties["resource"]
            metadata[n2.name] = resource ? Name.find_in_names(resource.split("/").last, @names) : n2.content.strip
          end
          
          locations = @libxml.root.find("rdf:Description/c:subject[contains(@rdf:resource, '#{hash}')]/..").map do |n2|
            start = n2.find_first("c:offset").content.to_i
            Range.new(start, start+n2.find_first("c:length").content.to_i)
          end
          
          
          @relationships << Relationship.new(
            :type => type,
            :hash => hash,
            :metadata => metadata,
            :locations => locations
          )
        end
      end
  end
end