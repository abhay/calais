require 'digest/sha1'
require 'net/http'
require 'rexml/document'
require 'yaml'

$KCODE = "UTF8"

class Calais
  POST_URL = "http://api.opencalais.com"
  
  AVAILABLE_OUTPUT_FORMATS = {
    :rdf => "XML/RDF"
  }
  DEFAULT_OUTPUT_FORMAT = :rdf
  
  AVAILABLE_CONTENT_TYPES = {
    :xml => "TEXT/XML",
    :html => "TEXT/HTML",
    :text => "TEXT/TXT"
  }
  DEFAULT_CONTENT_TYPE = :xml
  
  DEFAULT_SUBMITTER = "calais.rb"
  
  AVAILABLE_METHODS = {
    :enlighten => "/enlighten/calais.asmx/Enlighten"
  }
  
  class << self
    def enlighten(*args, &block) Calais.new(*args, &block).call(:enlighten) end
  end
  
  attr_accessor :license_id
  attr_accessor :content
  attr_accessor :content_type, :output_format
  attr_accessor :allow_distribution, :allow_search, :submitter, :external_id
  attr_accessor :external_metadata
  
  def initialize(options={}, &block)
    @license_id = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'conf', 'calais.yml')))['key']
    options.each {|k,v| send("#{k}=", v)}
    yield(self) if block_given?
  end
  
  def call(method)
    method = method.intern unless method.is_a?(Symbol)
    raise ArgumentError.new("Unknown method: #{method}") unless AVAILABLE_METHODS.keys.include? method
    
    post_args = {
      "licenseID" => @license_id,
      "content" => @content,
      "paramsXML" => params_xml
    }
    
    url = URI.parse(POST_URL + AVAILABLE_METHODS[method])
    
    resp, data = Net::HTTP.post_form(url, post_args)
    
    case resp
    when Net::HTTPOK
      doc = REXML::Document.new(data)
      doc.root.text
    else
      raise ServiceError.new("OpenCalais Service Error (#{resp})")
    end
  end
  
  class ServiceError < Exception; end
  
  private
    def params_xml
      content_type = @content_type && AVAILABLE_CONTENT_TYPES.keys.include?(@content_type) ? AVAILABLE_CONTENT_TYPES[@content_type] : AVAILABLE_CONTENT_TYPES[DEFAULT_CONTENT_TYPE]
      output_format = @output_format && AVAILABLE_OUTPUT_FORMATS.keys.include?(@output_format) ? AVAILABLE_OUTPUT_FORMATS[@output_format] : AVAILABLE_OUTPUT_FORMATS[DEFAULT_OUTPUT_FORMAT]
      allow_distribution = @allow_distribution ? "true" : "false"
      allow_search = @allow_search ? "true" : "false"
      submitter = @submitter || DEFAULT_SUBMITTER
      external_id = @external_id || Digest::SHA1.hexdigest(@content.inspect)
      external_metadata = @external_metadata || ""
      
      xml  = %[<c:params xmlns:c="http://s.opencalais.com/1/pred/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">]
      xml += %[<c:processingDirectives c:contentType="#{content_type}" c:outputFormat="#{output_format}"></c:processingDirectives>]
      xml += %[<c:userDirectives c:allowDistribution="#{allow_distribution}" c:allowSearch="#{allow_search}" c:externalID="#{external_id}" c:submitter="#{submitter}"></c:userDirectives>]
      xml += %[<c:externalMetadata>#{external_metadata}</c:externalMetadata>]
      xml += %[</c:params>]
    end
end

class Calais
  VERSION = '0.0.1'
end
