module Calais
  class Response
    MATCHERS = {
      :docinfo => 'DocInfo',
      :docinfometa => 'DocInfoMeta',
      :defaultlangid => 'DefaultLangId',
      :doccat => 'DocCat',
      :entities => 'type/em/e',
      :relations => 'type/em/r',
      :geographies => 'type/er',
      :instances => 'type/sys/InstanceInfo',
      :relevances => 'type/sys/RelevanceInfo',
    }
    
    attr_accessor :hashes, :entities, :relations, :geographies
  
    def initialize(rdf_string)
      @raw_response = rdf_string
      
      @hashes = []
      @entities = []
      @relations = []
      @geographies = []
      
      extract_data
      process_entities
      process_relations
      process_geographies
    end
    
    class Entity
      attr_accessor :hash, :type, :attributes
    end
    
    class Relation
      attr_accessor :hash, :type, :attributes
    end
    
    class Geography
      attr_accessor :name, :hash, :attributes
    end
    
    class CalaisHash
      attr_accessor :value
      
      def self.find_or_create(hash, hashes)
        selected = hashes.select {|h| h.value }
        
        if selected.empty?
          new_hash = self.new
          new_hash.value = hash
          hashes << new_hash
          new_hash
        else
          selected.first
        end
      end
    end
    
    private
      def extract_data
        doc = XML::Parser.string(@raw_response).parse
        
        @nodes = {}
        @nodes[:docinfo] = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:docinfo]}')]/..")
        @nodes[:docinfo].each { |node| node.remove! }
        
        @nodes[:docinfometa] = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:docinfometa]}')]/..")
        @nodes[:docinfometa].each { |node| node.remove! }
        
        @nodes[:defaultlangid] = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:defaultlangid]}')]/..")
        @nodes[:defaultlangid].each { |node| node.remove! }
        
        @nodes[:doccat] = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:doccat]}')]/..")
        @nodes[:doccat].each { |node| node.remove! }
        
        @nodes[:entities] = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:entities]}')]/..")
        @nodes[:entities].each { |node| node.remove! }
        
        @nodes[:relations] = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:relations]}')]/..")
        @nodes[:relations].each { |node| node.remove! }
        
        @nodes[:geographies] = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:geographies]}')]/..")
        @nodes[:geographies].each { |node| node.remove! }
        
        @nodes[:instances] = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:instances]}')]/..")
        @nodes[:instances].each { |node| node.remove! }
        
        @nodes[:relevances] = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:relevances]}')]/..")
        @nodes[:relevances].each { |node| node.remove! }
        
        @nodes[:others] = doc.root.find("./*")
        @nodes[:others].each { |node| node.remove! }
        
        return
      end
      
      def extract_attributes(nodes)
        nodes.inject({}) do |hsh, node|
          value = if node['resource']
              extracted_hash = node['resource'].split('/')[-1] rescue nil
              CalaisHash.find_or_create(extracted_hash, @hashes)
            else
              node.content
            end
          hsh.merge(node.name => value)
        end
      end
      
      def process_entities
        @entities = @nodes[:entities].map do |node|
          extracted_hash = node['about'].split('/')[-1] rescue nil
          
          entity = Entity.new
          entity.hash = CalaisHash.find_or_create(extracted_hash, @hashes)
          entity.type = node.find("*[name()='rdf:type']")[0]['resource'].split('/')[-1] rescue nil
          entity.attributes = extract_attributes(node.find("*[contains(name(), 'c:')]"))
          
          entity
        end
      end
      
      def process_relations
        @relations = @nodes[:relations].map do |node|
          extracted_hash = node['about'].split('/')[-1] rescue nil
          
          relation = Relation.new
          relation.hash = CalaisHash.find_or_create(extracted_hash, @hashes)
          relation.type = node.find("*[name()='rdf:type']")[0]['resource'].split('/')[-1] rescue nil
          relation.attributes = extract_attributes(node.find("*[contains(name(), 'c:')]"))
          
          relation
        end
      end
      
      def process_geographies
        @geographies = @nodes[:geographies].map do |node|
          attributes = extract_attributes(node.find("*[contains(name(), 'c:')]"))
          
          geography = Geography.new
          geography.name = attributes.delete('name')
          geography.hash = attributes.delete('subject')
          geography.attributes = attributes
          
          geography
        end
      end
  end
end