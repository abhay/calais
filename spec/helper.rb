require 'rubygems'
require 'spec'
require 'yaml'

require File.dirname(__FILE__) + '/../lib/calais'

SAMPLE_DOCUMENT = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'slovenia_euro.xml'))
LICENSE_KEY = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'conf', 'calais.yml')))['key']
