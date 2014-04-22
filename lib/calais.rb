require 'digest/sha1'
require 'net/http'
require 'uri'
require 'cgi'
require 'iconv' if RUBY_VERSION.to_f < 1.9
require 'set'
require 'date'

require 'rubygems'
require 'nokogiri'
require 'json'

if RUBY_VERSION.to_f < 1.9
  $KCODE = "UTF8"
  require 'jcode'
end

$:.unshift File.expand_path(File.dirname(__FILE__))

require 'calais/client'
require 'calais/response'
require 'calais/error'

module Calais
  REST_ENDPOINT = "http://api.opencalais.com/enlighten/rest/"
  BETA_REST_ENDPOINT = "http://beta.opencalais.com/enlighten/rest/"

  AVAILABLE_CONTENT_TYPES = {
    :xml => 'text/xml',
    :html => 'text/html',
    :htmlraw => 'text/htmlraw',
    :raw => 'text/raw'
  }

  AVAILABLE_OUTPUT_FORMATS = {
    :rdf => 'xml/rdf',
    :simple => 'text/simple',
    :microformats => 'text/microformats',
    :json => 'application/json'
  }

  KNOWN_ENABLES = ['GenericRelations', 'SocialTags']
  KNOWN_DISCARDS = ['er/Company', 'er/Geo', 'er/Product']

  MAX_RETRIES = 5
  HTTP_TIMEOUT = 60
  MIN_CONTENT_SIZE = 1
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
