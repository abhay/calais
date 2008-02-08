require 'digest/sha1'
require 'net/http'
require 'yaml'
require 'cgi'

require 'rubygems'
require 'hpricot'

$KCODE = "UTF8"

Dir.glob(File.join(File.dirname(__FILE__), 'calais/*.rb')).each { |f| require f }

module Calais
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
  
  MAX_RETRIES = 5
  
  class << self
    def enlighten(*args, &block) Client.new(*args, &block).call(:enlighten) end
    def process_document(*args, &block) 
      data, error = Calais.enlighten(*args, &block)
      Client.process_data(data, error)
    end
  end
end

module Calais
  VERSION = '0.0.3'
end
