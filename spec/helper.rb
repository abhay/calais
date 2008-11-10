require 'rubygems'
require 'spec'
require 'yaml'

require File.dirname(__FILE__) + '/../lib/calais'

FIXTURES_DIR = File.join File.dirname(__FILE__), %[fixtures]
SAMPLE_DOCUMENT = File.read(File.join(FIXTURES_DIR, %[bicycles_australia.xml]))
SAMPLE_RESPONSE = File.read(File.join(FIXTURES_DIR, %[bicycles_australia.response.rdf]))
LICENSE_ID = YAML.load(File.read(File.join(FIXTURES_DIR, %[calais.yml])))['key']
