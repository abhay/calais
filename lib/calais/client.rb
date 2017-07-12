module Calais
  class Client
    # base attributes of the call
    attr_accessor :content
    attr_accessor :license_id

    # processing directives
    attr_accessor :content_type, :output_format, :reltag_base_url, :calculate_relevance, :omit_outputting_original_text

    attr_accessor :external_metadata

    def initialize(options={})
      options.each {|k,v| send("#{k}=", v)}
      yield(self) if block_given?
    end

    def enlighten
      check_params
      post_args = {
        "licenseID" => @license_id,
        "content" => "#{@content}".encode(Encoding::UTF_8, :invalid => :replace, :undef => :replace, :replace => '')[0 .. -2],
        "contentType" => AVAILABLE_CONTENT_TYPES[@content_type],
        "outputFormat" => AVAILABLE_OUTPUT_FORMATS[@output_format]
      }

      do_request(post_args)
    end

    def url
      @url ||= URI.parse(REST_ENDPOINT)
    end

    private
      def check_params
        raise 'missing content' if @content.nil? || @content.empty?

        content_length = @content.length
        raise 'content is too small' if content_length < MIN_CONTENT_SIZE
        raise 'content is too large' if content_length > MAX_CONTENT_SIZE

        raise 'missing license id' if @license_id.nil? || @license_id.empty?

        raise 'unknown content type' unless AVAILABLE_CONTENT_TYPES.keys.include?(@content_type)
        raise 'unknown output format' unless AVAILABLE_OUTPUT_FORMATS.keys.include?(@output_format) if @output_format
      end

      def do_request(post_fields)
        @request ||= Net::HTTP::Post.new(url.path)
        @request['x-ag-access-token'] = post_fields["licenseID"]
        @request['Content-Type'] = post_fields["contentType"]
        @request['outputFormat'] = post_fields["outputFormat"]
        @request.body = post_fields["content"]
        stuff = Net::HTTP.new(url.host, url.port)
        stuff.use_ssl = true
        stuff.start {|http| http.request(@request)}.body
      end
  end
end
