module Calais
  class Client
    # base attributes of the call
    attr_accessor :content
    attr_accessor :license_id

    # processing directives
    attr_accessor :content_type, :output_format, :reltag_base_url, :calculate_relevance, :omit_outputting_original_text
    attr_accessor :metadata_enables, :metadata_discards

    # user directives
    attr_accessor :allow_distribution, :allow_search, :external_id, :submitter

    attr_accessor :external_metadata

    attr_accessor :use_beta

    def initialize(options={}, &block)
      options.each {|k,v| send("#{k}=", v)}
      yield(self) if block_given?
    end

    def enlighten
      post_args = {
        "licenseID" => @license_id,
        "content" => Iconv.iconv('UTF-8//IGNORE', 'UTF-8',  "#{@content} ").first[0..-2],
        "paramsXML" => params_xml
      }

      @client ||= Curl::Easy.new
      @client.url = @use_beta ? BETA_REST_ENDPOINT : REST_ENDPOINT
      @client.timeout = HTTP_TIMEOUT

      post_fields = post_args.map {|k,v| Curl::PostField.content(k, v) }

      do_request(post_fields)
    end

    def params_xml
      check_params

      params_node = XML::Node.new('c:params')
      params_node['xmlns:c'] = 'http://s.opencalais.com/1/pred/'
      params_node['xmlns:rdf'] = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'

      processing_node = XML::Node.new('c:processingDirectives')
      processing_node['c:contentType'] = AVAILABLE_CONTENT_TYPES[@content_type] if @content_type
      processing_node['c:outputFormat'] = AVAILABLE_OUTPUT_FORMATS[@output_format] if @output_format
      processing_node['c:reltagBaseURL'] = @reltag_base_url.to_s if @reltag_base_url

      processing_node['c:enableMetadataType'] = @metadata_enables.join(';') unless @metadata_enables.empty?
      processing_node['c:discardMetadata'] = @metadata_discards.join(';') unless @metadata_discards.empty?
      processing_node['c:omitOutputtingOriginalText'] = 'true' if @omit_outputting_original_text

      user_node = XML::Node.new('c:userDirectives')
      user_node['c:allowDistribution'] = @allow_distribution.to_s unless @allow_distribution.nil?
      user_node['c:allowSearch'] = @allow_search.to_s unless @allow_search.nil?
      user_node['c:externalID'] = @external_id.to_s if @external_id
      user_node['c:submitter'] = @submitter.to_s if @submitter

      params_node << processing_node
      params_node << user_node

      if @external_metadata
        external_node = XML::Node.new('c:externalMetadata')
        external_node << @external_metadata
        params_node << external_node
      end

      params_node.to_s
    end

    private
      def check_params
        raise 'missing content' if @content.nil? || @content.empty?

        content_length = @content.length
        raise 'content is too small' if content_length < MIN_CONTENT_SIZE
        raise 'content is too large' if content_length > MAX_CONTENT_SIZE

        raise 'missing license id' if @license_id.nil? || @license_id.empty?

        raise 'unknown content type' unless AVAILABLE_CONTENT_TYPES.keys.include?(@content_type) if @content_type
        raise 'unknown output format' unless AVAILABLE_OUTPUT_FORMATS.keys.include?(@output_format) if @output_format

        %w[calculate_relevance allow_distribution allow_search].each do |variable|
          value = self.send(variable)
          unless NilClass === value || TrueClass === value || FalseClass === value
            raise "expected a boolean value for #{variable} but got #{value}"
          end
        end

        @metadata_enables ||= []
        unknown_enables = Set.new(@metadata_enables) - KNOWN_ENABLES
        raise "unknown metadata enables: #{unknown_enables.to_ainspect}" unless unknown_enables.empty?

        @metadata_discards ||= []
        unknown_discards = Set.new(@metadata_discards) - KNOWN_DISCARDS
        raise "unknown metadata discards: #{unknown_discards.to_ainspect}" unless unknown_discards.empty?
      end

      def do_request(post_fields)
        unless @client.http_post(post_fields)
          raise 'unable to post to api endpoint'
        end

        @client.body_str
      end
  end
end