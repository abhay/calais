require 'digest/sha1'
require 'soap/wsdlDriver'
require 'rexml/document'
require 'yaml'

$KCODE = "UTF8"

class Calais
  API_URL = "http://api.opencalais.com/calais/calais.asmx"
  WSDL_URL = "http://api.opencalais.com/calais/?wsdl"
  
  AVAILABLE_OUTPUT_FORMATS = ["XML/RDF"]
  DEFAULT_OUTPUT_FORMAT = "XML/RDF"
  
  AVAILABLE_CONTENT_TYPES = ["TEXT/XML", "TEXT/TXT", "TEXT/HTML"]
  DEFAULT_CONTENT_TYPE = "TEXT/TXT"
  
  DEFAULT_SUBMITTER = "calais.rb"
  
  AVAILABLE_METHODS = ["enlighten"]
  
  class << self
    def enlighten(*args, &block) Calais.new(*args, &block).call('enlighten') end
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
    raise ArgumentError.new("Unknown method: #{method}") unless AVAILABLE_METHODS.include? method
    
    soap = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    response = soap.send(method.capitalize, :licenseID => @license_id, :content => @content, :paramsXML => params_xml)
    soap.reset_stream
    
    response.send("#{method}Result")
  end

  class ServiceError < Exception; end
  
  private
    def params_xml
      content_type = @content_type && AVAILABLE_CONTENT_TYPES.include?(@content_type) ? @content_type : DEFAULT_CONTENT_TYPE
      output_format = @output_format && AVAILABLE_OUTPUT_FORMATS.include?(@output_format) ? @output_format : DEFAULT_OUTPUT_FORMAT
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
