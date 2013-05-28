# -*- encoding: utf-8 -*-

require File.expand_path("../lib/calais/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'calais'
  gem.version = Calais::VERSION
	gem.date    = Date.today.to_s

	gem.summary = 'A Ruby interface to the Calais Web Service'
	gem.description = 'A Ruby interface to the Calais Web Service'

	gem.authors = ['enigmatic00']
	gem.homepage = 'https://github.com/enigmatic00/calais'

	gem.add_dependency("nokogiri", ">= 1.3.3")
  gem.add_dependency("json", ">= 1.1.3")

  gem.add_development_dependency("rspec", ">= 2.9.0")

  gem.files = Dir[
    "CHANGELOG.markdown",
     "Gemfile",
     "MIT-LICENSE",
     "README.markdown",
     "Rakefile",
		 "{bin,lib,man,test,spec}/**/*"
  ] & `git ls-files`.split("\n")
end
