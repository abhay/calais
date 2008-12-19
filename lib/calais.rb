require 'digest/sha1'
require 'net/http'
require 'cgi'
require 'iconv'
require 'set'

require 'rubygems'
require 'xml/libxml'
require 'json'
require 'curb'

$KCODE = "UTF8"
require 'jcode'

$:.unshift File.expand_path(File.dirname(__FILE__)) + '/calais'

require 'client'
require 'response'

module Calais
  REST_ENDPOINT = "http://api.opencalais.com/enlighten/rest/"
  BETA_REST_ENDPOINT = "http://beta.opencalais.com/enlighten/rest/"

  AVAILABLE_CONTENT_TYPES = {
    :xml => 'text/xml',
    :text => 'text/txt',
    :html => 'text/html',
    :raw => 'text/raw'
  }

  AVAILABLE_OUTPUT_FORMATS = {
    :rdf => 'xml/rdf',
    :simple => 'text/simple',
    :microformats => 'text/microformats',
    :json => 'application/json'
  }

  KNOWN_ENABLES = ['GenericRelations']
  KNOWN_DISCARDS = ['er/Company', 'er/Geo']

  MAX_RETRIES = 5
  HTTP_TIMEOUT = 60
  MIN_CONTENT_SIZE = 100
  MAX_CONTENT_SIZE = 100_000

  class << self
    def enlighten(*args, &block); Client.new(*args, &block).enlighten; end

    def process_document(*args, &block)
      client = Client.new(*args, &block)
      client.output_format = :rdf
      Response.new(client.enlighten)
    end
  end
end

module Calais
  VERSION = '0.0.6'
end