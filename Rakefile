# -*- ruby -*-

require 'rake'
require 'rake/clean'

require './lib/calais.rb'

begin
	require 'rspec/core/rake_task'

	RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  puts "RSpec, or one of its dependencies, is not available. Please install it."
  exit(1)
end

begin
  require 'yard'
  require 'yard/rake/yardoc_task'

  YARD::Rake::YardocTask.new do |t|
    t.options = ["--verbose", "--markup=markdown", "--files=CHANGELOG.markdown,MIT-LICENSE"]
  end
  
  task :rdoc => :yardoc
  
  CLOBBER.include 'doc'
  CLOBBER.include '.yardoc'
rescue LoadError
  puts "Yard, or one of its dependencies is not available. Please install it."
  exit(1)
end

# vim: syntax=Ruby
