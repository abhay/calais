require 'rubygems'
require 'rspec'
require 'yaml'

require File.dirname(__FILE__) + '/../lib/calais'

FIXTURES_DIR = File.join File.dirname(__FILE__), %[fixtures]
SAMPLE_DOCUMENT = File.read(File.join(FIXTURES_DIR, %[bicycles_australia.xml]))
SAMPLE_RESPONSE = File.read(File.join(FIXTURES_DIR, %[bicycles_australia.response.rdf]))
SAMPLE_RESPONSE_WITH_NO_SCORE = File.read(File.join(FIXTURES_DIR, %[twitter_tweet_without_score.response.rdf]))
RESPONSE_WITH_EXCEPTION = File.read(File.join(FIXTURES_DIR, %[error.response.xml]))
LICENSE_ID = YAML.load(File.read(File.join(FIXTURES_DIR, %[calais.yml])))['key']

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
