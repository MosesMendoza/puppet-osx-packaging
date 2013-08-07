#   Title:        OS-X Packaging
#   Author:       Moses Mendoza
#   Copyright:    Puppet Labs, 2013
#   Description:  Rake tasks to load the packages.json file and call
#                 packages-specific build tasks under their respective directories

RAKE_ROOT = File.dirname(__FILE__)
PACKAGES = File.join(RAKE_ROOT, 'packages.json')
SOURCES = File.join(RAKE_ROOT, "sources")
PREFIX = "/opt/puppet"
CONFDIR = "/etc/puppetlabs"

require 'json'
require 'digest'

load File.join(RAKE_ROOT, 'utility_methods.rb')
load File.join(RAKE_ROOT, "ruby", "build.rake")



desc "Remove downloaded and built files"
task :clean do
  [PREFIX, CONFDIR, SOURCES, File.join(RAKE_ROOT, "bom")].each do |f|
    rm_rf Dir["#{f}/*"]
  end
end

# Tasks for building the various components of the stack
desc "Build All"
task :all => :ruby

desc "Build ruby"
task :ruby => [:setup, "ruby:build", "bom/ruby.post.list", "bom/ruby.lst"]

task :setup do
  mkdir_p workdir
  @packages = JSON.load(File.read(PACKAGES))
end

namespace :bom do
  # Generate the list that contains the original file structure. We use this later to
  # get the newly installed files.
  rule '.list' do |t|
    sh %[ echo > #{t.name};
      for i in #{PREFIX} #{CONFDIR};
      do
        [ -d $i ] && find $i \\! -type d -print;
      done | sort >> #{t.name}]
  end

  rule '.lst' do |t|
    sh %[comm -23 #{t.name.sub('.lst','.post.list')} #{t.name.sub('.lst','.pre.list')} > #{t.name}]
  end

end
