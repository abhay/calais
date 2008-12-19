== Calais
A Ruby interface to the Open Calais Web Service (http://opencalais.com)

== Features

* Accepts documents in text/plain, text/xml and text/html format.
* Basic access to the Open Calais API's Enlighten action.
	* Output is RDF representation of input document.
* Single function ability to extract names, entities and geographies from given text.
  
== Synopsis

This is a very basic wrapper to the Open Calais API. It uses the POST endpoint and currently supports the Enlighten action. Here's a simple call:

  Calais.enlighten(:content => "The government of the United Kingdom has given corporations like fast food chain McDonald's the right to award high school qualifications to employees who complete a company training program.", :content_type => :text, :license_id => LICENSE_ID)

This is the easiest way to get the RDF-formated response from the OpenCalais service.

If you want to do something more fun like getting all sorts of fun information about a document, you can try this:
  
  Calais.process_document(:content => "The government of the United Kingdom has given corporations like fast food chain McDonald's the right to award high school qualifications to employees who complete a company training program.", :content_type => :text, :license_id => LICENSE_ID)

This will return an object containing information extracted from the RDF response.

== Requirements

* Ruby 1.8.5 or better
  * Uses the following standard libraries: digest/sha1, net/http, yaml, cgi
* libxml2 / libxml-ruby
* curb, libcurl

== Install

You can install the Calais gem via Rubygems (gem install calais) or by building from source.

== Authors

Abhay Kumar
http://opensynapse.net

== Acknowledgements

* Paul Legato (http://www.economaton.com/). Help all around with the new response processor and implementation of the latest API.