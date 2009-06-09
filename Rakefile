# -*- ruby -*-

require 'rake'
require 'rake/clean'

require './lib/calais.rb'

begin
  gem 'jeweler', '>= 1.0.1'
  require 'jeweler'

  Jeweler::Tasks.new do |s|
    s.name = 'calais'
    s.summary = 'A Ruby interface to the Calais Web Service'
    s.email = 'gems@opensynapse.net'
    s.homepage = 'http://github.com/abhay/calais'
    s.description = 'A Ruby interface to the Calais Web Service'
    s.authors = ['Abhay Kumar']
    s.files = FileList["[A-Z]*", "{bin,generators,lib,test}/**/*"]
    s.rubyforge_project = 'calais'
    s.add_dependency 'libxml-ruby', '>= 0.5.4'
    s.add_dependency 'json', '>= 1.1.3'
    s.add_dependency 'curb', '>= 0.1.4'
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Please install it."
  exit(1)
end

begin
  require 'spec/rake/spectask'

  desc "Run all specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"].sort
    t.spec_opts = ["--options", "spec/spec.opts"]
  end

  desc "Run all specs and get coverage statistics"
  Spec::Rake::SpecTask.new('coverage') do |t|
    t.spec_opts = ["--options", "spec/spec.opts"]
    t.spec_files = FileList["spec/*_spec.rb"].sort
    t.rcov_opts = ["--exclude", "spec", "--exclude", "gems"]
    t.rcov = true
  end

  task :default => :spec
rescue LoadError
  puts "RSpec, or one of its dependencies, is not available. Please install it."
  exit(1)
end

begin
  require 'yard'
  require 'yard/rake/yardoc_task'

  YARD::Rake::YardocTask.new
  task :rdoc => :yardoc
  CLOBBER.include 'doc'
  CLOBBER.include '.yardoc'
rescue LoadError
  puts "Yard, or one of its dependencies is not available. Please install it."
  exit(1)
end

begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do

    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]

    namespace :release do
      desc "Publish RDoc to RubyForge."
      task :docs => [:yardoc] do
        config = YAML.load(
            File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/calais/"
        local_dir = 'doc'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
  exit(1)
end

# vim: syntax=Ruby
