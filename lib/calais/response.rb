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

    attr_accessor :submitter_code, :signature, :language, :submission_date, :request_id, :doc_title, :doc_date
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

        doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:docinfometa]}')]/..").each do |node|
          @language = node['language']
          @submission_date =  DateTime.parse node['submissionDate']

          attributes = extract_attributes(node.find("*[contains(name(), 'c:')]"))

          @signature = attributes.delete('signature')
          @submitter_code = attributes.delete('submitterCode')

          node.remove!
        end

        doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:docinfo]}')]/..").each do |node|
          @request_id = node['calaisRequestID']

          attributes = extract_attributes(node.find("*[contains(name(), 'c:')]"))

          @doc_title = attributes.delete('docTitle')
          @doc_date = Date.parse attributes.delete('docDate')

          node.remove!
        end

        @categories = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:doccat]}')]/..").map do |node|
          category = Category.new
          category.name = node.find_first("c:categoryName").content
          category.score = node.find_first("c:score").content.to_f

          node.remove!
          category
        end

        @relevances = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:relevances]}')]/..").inject({}) do |acc, node|
          subject_hash = node.find_first("c:subject")[:resource].split('/')[-1]
          acc[subject_hash] = node.find_first("c:relevance").content.to_f

          node.remove!
          acc
        end

        @entities = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:entities]}')]/..").map do |node|
          extracted_hash = node['about'].split('/')[-1] rescue nil

          entity = Entity.new
          entity.hash = CalaisHash.find_or_create(extracted_hash, @hashes)
          entity.type = extract_type(node)
          entity.attributes = extract_attributes(node.find("*[contains(name(), 'c:')]"))

          entity.relevance = @relevances[extracted_hash]
          entity.instances = extract_instances(doc, extracted_hash)

          node.remove!
          entity
        end

        @relations = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:relations]}')]/..").map do |node|
          extracted_hash = node['about'].split('/')[-1] rescue nil

          relation = Relation.new
          relation.hash = CalaisHash.find_or_create(extracted_hash, @hashes)
          relation.type = extract_type(node)
          relation.attributes = extract_attributes(node.find("*[contains(name(), 'c:')]"))
          relation.instances = extract_instances(doc, extracted_hash)

          node.remove!
          relation
        end

        @geographies = doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:geographies]}')]/..").map do |node|
          attributes = extract_attributes(node.find("*[contains(name(), 'c:')]"))

          geography = Geography.new
          geography.name = attributes.delete('name')
          geography.hash = attributes.delete('subject')
          geography.attributes = attributes

          node.remove!
          geography
        end

        doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:defaultlangid]}')]/..").each { |node| node.remove! }
        doc.root.find("./*").each { |node| node.remove! }

        return
      end

      def extract_instances(doc, hash)
        doc.root.find("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:instances]}')]/..").select do |instance_node|
          instance_node.find_first("c:subject")[:resource].split("/")[-1] == hash
        end.map do |instance_node|
          instance = Instance.from_node(instance_node)
          instance_node.remove!

          instance
        end
      end

      def extract_type(node)
        node.find("*[name()='rdf:type']")[0]['resource'].split('/')[-1]
      rescue
        nil
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
  end
end