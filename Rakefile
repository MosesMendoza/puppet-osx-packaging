#   Title:        OS-X Packaging
#   Author:       Moses Mendoza
#   Copyright:    Puppet Labs, 2013
#   Description:  Rake tasks to load the packages.json file and call
#                 packages-specific build tasks under their respective directories

RAKE_ROOT = File.dirname(__FILE__)
PACKAGES = File.join(RAKE_ROOT, 'packages.json')
PREFIX = "/opt/puppet"
CONFDIR = "/etc/puppetlabs"

require 'json'
require 'digest'

load File.join(RAKE_ROOT, 'utility_methods.rb')
load File.join(RAKE_ROOT, "ruby", "build.rake")



desc "Remove downloaded and built files"
task :clean do
  [PREFIX, CONFDIR, File.join(RAKE_ROOT, "bom")].each do |f|
    rm_rf f
  end
end

# Tasks for building the various components of the stack
desc "Build All"
task :all => :ruby

desc "Build ruby"
task :ruby => [:setup, "ruby:build", "bom/ruby.post.list"]

desc "Setup work dir"
task :setup do
  mkdir_p workdir
  @packages = JSON.load(File.read(PACKAGES))
end

namespace :bom do
  # Generate the list that contains the original file structure. We use this later to
  # get the newly installed files.
  rule '.list' do |t|
    sh %[ echo > #{t.name};
      for i in #{PREFIX} /etc/puppet #{CONFDIR};
      do
        [ -d $i ] && find $i \\! -type d -print;
      done | sort >> #{t.name}]
  end

  rule '.lst' => ['.o.list', '.f.list'] do |t|
    sh %[comm -23 #{t.name.sub('.lst','.f.list')} #{t.name.sub('.lst','.o.list')} > #{t.name}]
  end

  desc "Create bom/ruby.lst (for tar -T)"
  task :'ruby' => "bom/ruby.lst" do
    puts "bom/ruby.lst created!"
  end
end
