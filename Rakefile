#   Title:        OSX-Packaging
#   Author:       Moses Mendoza
#   Copyright:    Puppet Labs, 2013
#   Description:  Rake tasks to load the packages.json file and call
#                 packages-specific build tasks under their respective directories

RAKE_ROOT = File.dirname(__FILE__)
PACKAGES  = File.join(RAKE_ROOT, 'packages.json')
SOURCES   = File.join(RAKE_ROOT, "sources")
PREFIX    = "/opt/puppet"
CONFDIR   = "/etc/puppetlabs"
TAR       = %x{which tar}.chomp
PKGBUILD  = %x{which pkgbuild}.chomp

require 'json'
require 'digest'

load File.join(RAKE_ROOT, 'utility_methods.rb')
load File.join(RAKE_ROOT, "ruby", "build.rake")



desc "Remove downloaded files"
task :clean do
  [SOURCES, File.join(RAKE_ROOT, "bom")].each do |f|
    rm_rf Dir["#{f}/*"]
  end
end

desc "Remove downloaded AND built files"
task :clobber => :clean do
  [PREFIX, CONFDIR].each do |f|
    rm_rf f
  end
end

# Tasks for building the various components of the stack
desc "Build All"
task :all => :ruby

desc "Build ruby"
task :ruby => [:tree, "ruby.info", "ruby:build", "ruby.pkg"]


# description:  Load package-specific info into variables, retrieve and verify
#               source. Instance variables such as @file are re-populated
#               with different package info as we move from package to package
rule '.info' do |t|
  @name     = "#{t.name.split('.')[0]}"
  @info     = @packages[@name]
  @file     = @info["file"]
  @version  = @info["version"]
  @url      = @info["url"]
  @md5      = @info["md5"] 
end

task :source_setup => :verify do
  cp(File.join(SOURCES,@file), @workdir)
  untar(File.join(@workdir,@file), @workdir)
end

task :verify => :retrieve do
  unless @md5.to_sym == Digest::MD5.file(File.join(SOURCES,@file)).hexdigest.to_sym
    fail "Sums don't match for #{@file}"
  end
end

task :retrieve do
  rm_f File.join(SOURCES,@file)
  sh "wget #{@url} -P #{SOURCES}"
end

# description: This task sets up the directory tree structure that packagemaker
#              needs to build a package. A prototype.plist file (holding
#              package-specific options) is built from an ERB template located
#              in the project directory
task :tree => :setup do
  @working_tree  = {
     'scripts'   => "#{workdir}/scripts",
     'resources' => "#{workdir}/resources",
     'working'   => "#{workdir}/root",
     'payload'   => "#{workdir}/payload",
  }
  @working_tree.each_value do |val|
    mkdir_p(val)
  end
end


task :setup do
  mkdir_p workdir
  @packages = JSON.load(File.read(PACKAGES))
end

# Generate the list that contains the original file structure. We use this
# later to get the newly installed files.
rule '.list' do |t|
  sh %[ echo > bom/#{t.name};
    for i in #{PREFIX} #{CONFDIR};
    do
      [ -d $i ] && find $i \\! -type d -print;
    done | sort >> bom/#{t.name}]
end

# Generate a list of files based on the difference between two file lists -
# before build/install and after
rule '.lst' => "#{@name}.post.list" do |t|
  sh %[comm -23 bom/#{t.name.sub('.lst','.post.list')} bom/#{t.name.sub('.lst','.pre.list')} > bom/#{t.name}]
end

# Create a tarball of the built files from the .lst
rule '.tar' => "#{@name}.lst" do |t|
  puts "Creating #{t.name}.gz"
  sh %[ #{TAR} -T bom/#{t.name.sub('.tar','.lst')} -czf #{File.join(workdir, "#{t.name}.gz")} ]
end

# Unpack the tarball into a root to package up
rule '.root' => "#{@name}.tar" do |t|
  puts "Unpacking into #{workdir}/root"
  cd workdir do
    sh %[ #{TAR} -xzf #{t.name.sub('.root','.tar.gz')} -C root ]
  end
end

# Erb the Info.plist file from a generic template that contains the logic to
# describe the package
rule 'erb' => "#{@name}.root" do |t|
  puts "Generating Info.plist file"
  cd workdir do
    erb(File.join(RAKE_ROOT, 'prototype.plist.erb'), 'prototype.plist')
  end
end

# Use pkgbuild to create the pkg file from the contents of the root
rule 'pkg' => "#{@name}.erb" do |t|
  name = t.name.split('.')[0]
  cd workdir do
    sh %[ #{PKGBUILD} --root root \
      --scripts scripts \
      --identifier com.puppetlabs.#{name} \
      --version #{@version} \
      --install-location / \
      --ownership-preserve \
      payload/#{name}.pkg ]
    cp File.join("payload","#{name}.pkg"), File.join(RAKE_ROOT,'pkg')
  end
end

task :post => :clean do |t|
  rm_rf workdir
end
