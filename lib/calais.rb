require 'digest/sha1'
require 'net/http'
require 'cgi'
require 'iconv'

require 'rubygems'
require 'xml/libxml'

$KCODE = "UTF8"
require 'jcode'

$:.unshift File.expand_path(File.dirname(__FILE__)) + '/calais'

require 'client'

module Calais
  POST_URL = "http://api.opencalais.com"
  
  AVAILABLE_OUTPUT_FORMATS = {
    :rdf => "XML/RDF",
    :simple => "Text/Simple"
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
    def enlighten(*args, &block); Client.new(*args, &block).call(:enlighten); end
  end
end

module Calais
  VERSION = '0.0.5'
end
