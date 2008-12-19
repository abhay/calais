# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'spec/rake/spectask'

require './lib/calais.rb'

Hoe.new('calais', Calais::VERSION) do |p|
  p.rubyforge_name = 'calais'
  p.author = 'Abhay Kumar'
  p.summary = 'A Ruby interface to the Calais Web Service'
  p.description = p.paragraphs_of('README.txt', 1..9).join("\n\n")
  p.email = 'info@opensynapse.net'
  p.url = 'http://calais.rubyforge.org'
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.remote_rdoc_dir = ''
end

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

Rake::Task[:default].prerequisites.clear
task :default => :spec

# vim: syntax=Ruby
