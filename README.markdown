# Calais #
A Ruby interface to the [Open Calais Web Service](http://opencalais.com)

## June 12, 2017 updates##
made by Britney Wright

Gem broke due to updates to the Open Calais API.

- change API endpoint URL
- Simplified the API request call
- Added headers for required metadata
- Updated specs
- Added current [Open Calais API guide](https://raw.githubusercontent.com/snsdigitaldevs/calais/master/public/ThomsonReutersOpenCalaisAPIUserGuideR10_8.pdf) to gem for future reference, should the API change again.
- **Note**: key in in `circle.yml.sample` is old API key. Still active, but not the one we use in when passing arguments to the gem from the Holos app. 

---
## Features ##
* Accepts documents in text/plain, text/xml and text/html format.
* Basic access to the Open Calais API's Enlighten action.
    * Output is RDF representation of input document.
* Single function ability to extract names, entities and geographies from given text.

## Synopsis ##

This is a very basic wrapper to the Open Calais API. It uses the POST endpoint and currently supports the Enlighten action. Here's a simple call:

    Calais.enlighten(
        :content => "The government of the United Kingdom has given corporations like fast food chain McDonald's the right to award high school qualifications to employees who complete a company training program.",
        :content_type => :raw,
        :license_id => 'your license id'
    )

This is the easiest way to get the RDF-formated response from the OpenCalais service.

If you want to do something more fun like getting all sorts of fun information about a document, you can try this:

    Calais.process_document(
        :content => "The government of the United Kingdom has given corporations like fast food chain McDonald's the right to award high school qualifications to employees who complete a company training program.",
        :content_type => :raw,
        :license_id => 'your license id'
    )

This will return an object containing information extracted from the RDF response.

## Requirements ##

* [Ruby 1.8.5 or better](http://ruby-lang.org)
* [nokogiri](http://nokogiri.rubyforge.org/nokogiri/), [libxml2](http://xmlsoft.org/), [libxslt](http://xmlsoft.org/xslt/)
* [curb](http://curb.rubyforge.org/), [libcurl](http://curl.haxx.se/)
* [json](http://json.rubyforge.org/)

## Install ##

You can install the Calais gem via Rubygems (`gem install calais`) or by building from source.

## Authors ##

* [Abhay Kumar](http://opensynapse.net)

## Acknowledgements ##

* [Paul Legato](http://www.economaton.com/): Help all around with the new response processor and implementation of the 3.1 API.
* [Ryan Ong](http://www.ryanong.net/)
* [Juan Antonio Chavez](https://github.com/TheNaoX): Geographies relevance
