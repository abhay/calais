# Changes

## 0.0.11

* simple fix for some rubies not liking DateTime.parse without including date
* tests for SocialTags
* typo fix: SocailTag != SocialTag

## 0.0.10

* community patch to expose SocialTags

## 0.0.9

* updates related to API changes
* community patches to support bundler, support ruby 1.9

## 0.0.8

* community patches to use nokogiri

## 0.0.7
* verified 4.0 API
* moved gem packaging to `jeweler` and documentation to `yard`

## 0.0.6
* fully implemented 3.1 API

## 0.0.5
* fixed error where classes weren't being required in the proper order on Ubuntu (reported by Jon Moses)
* New things coming back from the API. Fixing in tests.

## 0.0.4
* changed dependency from `hpricot` to `libxml`
* unicode fun
* cleanup all around

## 0.0.3
* pluginized the library for Rails (thanks [pius](http://gitorious.org/projects/calais-au-rails))
* added helper methods name entity types from a response

## 0.0.2
* cleanup in the specs
* cleaner parsing
* location of named entities
* more data in relationships
* moved Names and Relationships

## 0.0.1
* Access to OpenCalais's Enlighten action
* Single method to process a document
    * Get relationships and names from a document
