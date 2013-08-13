#   Title:        OSX-Packaging
#   Author:       Moses Mendoza
#   Copyright:    Puppet Labs, 2013
#   Description:  Rake tasks to load the packages.json file and call
#                 packages-specific build tasks under their respective
#                 directories. Each specific build is packaged into a .pkg
#                 file, which is then packaged into a distribution. See
#                 productbuild and pkgbuild manpages.

RAKE_ROOT    = File.dirname(__FILE__)
PACKAGES     = File.join(RAKE_ROOT, 'packages.json')
SOURCES      = File.join(RAKE_ROOT, "sources")
PREFIX       = "/opt/puppet"
CONFDIR      = "/etc/puppetlabs"
BINDIR       = "#{PREFIX}/bin"
RUBY         = "#{BINDIR}/ruby"
TAR          = %x{which tar}.chomp
PKGBUILD     = %x{which pkgbuild}.chomp
PRODUCTBUILD = %x{which productbuild}.chomp

require 'json'
require 'digest'

load File.join(RAKE_ROOT, 'utility_methods.rb')

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

#   Tasks for building the various components of the stack. As they satisfy
#   dependencies of each other, they are built in a specific order. We build up
#   a dependency chain that we can't express through the abstracted rake tasks
desc "Build All"
task :all         => [:clobber, :dist]

task :dist        => 'ruby-rgen'

task :'ruby-rgen' => :facter

task :facter      => :ruby

task :ruby        => :libyaml

#  Compose all of the component packages into an Apple Product Distribution
#  see `man productbuild`
desc "Compose component packages into a PuppetEnterprise.pkg"
task :dist do
  cd "pkg" do
    packages = Dir["*.pkg"].map{|p| "--package #{p}"}.join(" ")
    sh "#{PRODUCTBUILD} #{packages} PuppetEnterprise.pkg"
  end
end


["ruby-rgen", "facter", "ruby", "libyaml"].each do |t|
  load File.join(RAKE_ROOT, t, "build.rake")
  desc "Build #{t}"
  task t => [:tree, "#{t}.info", "#{t}:build", "#{t}.post"]
end


#   Load package-specific info into variables, retrieve and verify
#   source. Instance variables such as @file are re-populated with different
#   package info as we move from package to package along the dependency chain
rule '.info' do |t|
  @name     = "#{t.name.split('.')[0]}"
  @info     = @packages[@name]
  @file     = @info["file"]
  @version  = @info["version"]
  @release  = @info["release"]
  @url      = @info["url"]
  @md5      = @info["md5"]
end

#   Retrieve, verify, and unpack the source for the project

task :source => :verify do
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

#     This task sets up the directory tree structure that packagemaker needs to
#     build a package. A prototype.plist file (holding package-specific
#     options) is built from an ERB template located in the project directory
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

#     Create the temporary base directory which will serve as the root for all
#     of the packaging operations
task :setup do
  mkdir_p workdir
  @packages = JSON.load(File.read(PACKAGES))
end

#   Generate the file list that contains the original file structure, before
#   installing a package. We diff this later to get a list of the newly
#   installed files.
rule '.list' do |t|
  sh %[ echo > bom/#{t.name};
    for i in #{PREFIX} #{CONFDIR};
    do
      [ -d $i ] && find $i \\! -type d -print;
    done | sort >> bom/#{t.name}]
end

#   Generate a list of files based on the difference between two file lists -
#   before build/install and afterwards
rule '.lst' => "#{@name}.post.list" do |t|
  sh %[comm -23 bom/#{t.name.sub('.lst','.post.list')} bom/#{t.name.sub('.lst','.pre.list')} > bom/#{t.name}]
end

#   Create a tarball of the built files from the .lst
rule '.tar' => "#{@name}.lst" do |t|
  puts "Creating #{t.name}.gz"
  sh %[ #{TAR} -T bom/#{t.name.sub('.tar','.lst')} -czf #{File.join(workdir, "#{t.name}.gz")} ]
end

#   Unpack the tarball into a root to package up
rule '.root' => "#{@name}.tar" do |t|
  puts "Unpacking into #{workdir}/root"
  cd workdir do
    sh %[ #{TAR} -xzf #{t.name.sub('.root','.tar.gz')} -C root ]
  end
end

#   Erb the Info.plist file from a generic template that contains the logic to
#   describe the package
rule 'erb' => "#{@name}.root" do |t|
  puts "Generating Info.plist file"
  cd workdir do
    erb(File.join(RAKE_ROOT, 'prototype.plist.erb'), 'prototype.plist')
  end
end

#   Use pkgbuild to create the pkg file from the contents of the root
rule 'pkg' => "#{@name}.erb" do |t|
  name = t.name.split('.')[0]
  cd workdir do
    sh %[ #{PKGBUILD} --root root \
      --scripts scripts \
      --identifier com.puppetlabs.#{name} \
      --version #{@version} \
      --install-location / \
      --ownership preserve \
      payload/#{name}.pkg ]
    cp File.join("payload","#{name}.pkg"), File.join(RAKE_ROOT,'pkg')
  end
end

#   After the build of a specific pkg component is complete, remove the working
#   directory, and then re-enable all Rake tasks to ensure we have a complete
#   build chain
rule 'post' => "#{@name}.pkg" do
  rm_rf workdir
  @workdir = nil
  ::Rake::Task.tasks.each {|t| t.reenable}
end
