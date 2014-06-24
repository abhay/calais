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
    attr_accessor :hashes, :entities, :relations, :geographies, :categories, :socialtags, :relevances

    def initialize(rdf_string)
      @raw_response = rdf_string

      @hashes = []
      @entities = []
      @relations = []
      @geographies = []
      @relevances = {} # key = String hash, val = Float relevance
      @categories = []
      @socialtags = []

      extract_data
    end

    class Entity
      attr_accessor :calais_hash, :type, :attributes, :relevance, :instances
    end

    class Relation
      attr_accessor :calais_hash, :type, :attributes, :instances
    end

    class Geography
      attr_accessor :name, :calais_hash, :attributes, :relevance
    end

    class Category
      attr_accessor :name, :score
    end

    class SocialTag
      attr_accessor :name, :importance
    end

    class Instance
      attr_accessor :prefix, :exact, :suffix, :offset, :length

      # Makes a new Instance object from an appropriate Nokogiri::XML::Node.
      def self.from_node(node)
        instance = self.new
        instance.prefix = node.xpath("c:prefix[1]").first.content
        instance.exact  = node.xpath("c:exact[1]").first.content
        instance.suffix = node.xpath("c:suffix[1]").first.content
        instance.offset = node.xpath("c:offset[1]").first.content.to_i
        instance.length = node.xpath("c:length[1]").first.content.to_i

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
        doc = Nokogiri::XML(@raw_response)

        if doc.root.xpath("/Error[1]").first
          raise Calais::Error, doc.root.xpath("/Error/Exception").first.content
        end

        doc.root.xpath("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:docinfometa]}')]/..").each do |node|
          @language = node['c:language']

          @submission_date =  DateTime.parse node['c:submissionDate']

          attributes = extract_attributes(node.xpath("*[contains(name(), 'c:')]"))

          @signature = attributes.delete('signature')
          @submitter_code = attributes.delete('submitterCode')

          node.remove
        end

        doc.root.xpath("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:docinfo]}')]/..").each do |node|
          @request_id = node['c:calaisRequestID']

          attributes = extract_attributes(node.xpath("*[contains(name(), 'c:')]"))

          @doc_title = attributes.delete('docTitle')
          @doc_date = Date.parse(attributes.delete('docDate'))

          node.remove
        end

        @socialtags = doc.root.xpath("rdf:Description/c:socialtag/..").map do |node|
          tag = SocialTag.new
          tag.name = node.xpath("c:name[1]").first.content
          tag.importance = node.xpath("c:importance[1]").first.content.to_i

          node.remove if node.xpath("c:categoryName[1]").first.nil?

          tag
        end

        @categories = doc.root.xpath("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:doccat]}')]/..").map do |node|
          category = Category.new
          category.name = node.xpath("c:categoryName[1]").first.content
          score = node.xpath("c:score[1]").first
          category.score = score.content.to_f unless score.nil?

          node.remove
          category
        end

        @relevances = doc.root.xpath("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:relevances]}')]/..").inject({}) do |acc, node|
          subject_hash = node.xpath("c:subject[1]").first['rdf:resource'].split('/')[-1]
          acc[subject_hash] = node.xpath("c:relevance[1]").first.content.to_f

          node.remove
          acc
        end

        @entities = doc.root.xpath("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:entities]}')]/..").map do |node|
          extracted_hash = node['rdf:about'].split('/')[-1] rescue nil

          entity = Entity.new
          entity.calais_hash = CalaisHash.find_or_create(extracted_hash, @hashes)

          entity.type = extract_type(node)
          entity.attributes = extract_attributes(node.xpath("*[contains(name(), 'c:')]"))

          entity.relevance = @relevances[extracted_hash]
          entity.instances = extract_instances(doc, extracted_hash)

          node.remove
          entity
        end

        @relations = doc.root.xpath("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:relations]}')]/..").map do |node|
          extracted_hash = node['rdf:about'].split('/')[-1] rescue nil

          relation = Relation.new
          relation.calais_hash = CalaisHash.find_or_create(extracted_hash, @hashes)
          relation.type = extract_type(node)
          relation.attributes = extract_attributes(node.xpath("*[contains(name(), 'c:')]"))
          relation.instances = extract_instances(doc, extracted_hash)

          node.remove
          relation
        end

        @geographies = doc.root.xpath("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:geographies]}')]/..").map do |node|
          attributes = extract_attributes(node.xpath("*[contains(name(), 'c:')]"))


          geography = Geography.new
          geography.name = attributes.delete('name')
          geography.calais_hash = node.xpath('c:subject').first['rdf:resource'].split('/')[-1] rescue nil
          geography.attributes = attributes

          geography.relevance = extract_relevance(geography.calais_hash )

          node.remove
          geography
        end

        doc.root.xpath("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:defaultlangid]}')]/..").each { |node| node.remove }
        doc.root.xpath("./*").each { |node| node.remove }

        return
      end

      def extract_instances(doc, hash)
        doc.root.xpath("rdf:Description/rdf:type[contains(@rdf:resource, '#{MATCHERS[:instances]}')]/..").select do |instance_node|
          instance_node.xpath("c:subject[1]").first['rdf:resource'].split("/")[-1] == hash
        end.map do |instance_node|
          instance = Instance.from_node(instance_node)
          instance_node.remove

          instance
        end
      end

      def extract_type(node)
        node.xpath("*[name()='rdf:type']")[0]['rdf:resource'].split('/')[-1]
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
      def extract_relevance(value)
        return @relevances[value]
      end
  end
end
