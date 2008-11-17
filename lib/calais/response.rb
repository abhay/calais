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

    attr_accessor :hashes, :entities, :relations, :geographies, :categories

    def initialize(rdf_string)
      @raw_response = rdf_string

      @hashes = []
      @entities = []
      @relations = []
      @geographies = []
      @relevances = {} # key = String hash, val = Float relevance
      @categories = []

      extract_data

      process_relevances
      process_entities
      process_relations
      process_geographies
      process_categories
    end

    class Entity
      attr_accessor :hash, :type, :attributes, :relevance, :instances
    end

    class Relation
      attr_accessor :hash, :type, :attributes, :instances
    end

    class Geography
      attr_accessor :name, :hash, :attributes
    end

    class Category
      attr_accessor :name, :score
    end

    class Instance
      attr_accessor :prefix, :exact, :suffix, :offset, :length

      # Makes a new Instance object from an appropriate LibXML::XML::Node.
      def self.from_node(node)
        instance = self.new
        instance.prefix = node.find_first("c:prefix").content
        instance.exact = node.find_first("c:exact").content
        instance.suffix = node.find_first("c:suffix").content
        instance.offset = node.find_first("c:offset").content.to_i
        instance.length = node.find_first("c:length").content.to_i

        instance
      end
    end

    class CalaisHash
      attr_accessor :value

      def self.find_or_create(hash, hashes)
        if !selected = hashes.select {|h| h.value == hash }.first
          selected = self.new
          selected.value = hash
          hashes << selected
        end

        selected
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

      def process_relevances
        @nodes[:relevances].each do |node|
          subject_hash = node.find_first("c:subject")[:resource].split('/')[-1]

          @relevances[subject_hash] = node.find_first("c:relevance").content.to_f
        end

        @relevances
      end

      def process_categories
        @categories = @nodes[:doccat].map do |node|
          category = Category.new
          category.name = node.find_first("c:categoryName").content
          category.score = node.find_first("c:score").content.to_f

          category
        end
      end

      def process_entities
        @entities = @nodes[:entities].map do |node|
          extracted_hash = node['about'].split('/')[-1] rescue nil

          entity = Entity.new
          entity.hash = CalaisHash.find_or_create(extracted_hash, @hashes)
          entity.type = node.find("*[name()='rdf:type']")[0]['resource'].split('/')[-1] rescue nil
          entity.attributes = extract_attributes(node.find("*[contains(name(), 'c:')]"))

          relevance = @relevances[extracted_hash]
          entity.relevance = relevance if relevance

          instance_nodes = @nodes[:instances].select {|n|
            n.find_first("c:subject")[:resource].split("/")[-1] == extracted_hash
          }

          entity.instances = instance_nodes.map {|n| Instance.from_node(n) }

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

          instance_nodes = @nodes[:instances].select {|n|
            n.find_first("c:subject")[:resource].split("/")[-1] == extracted_hash
          }

          relation.instances = instance_nodes.map {|n| Instance.from_node(n) }

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
