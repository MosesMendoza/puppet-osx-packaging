# Task to build ruby from source and package as a .pkg file

namespace :ruby do
  task :build => [:clobber, :info, "ruby.pre.list", :setup] do
    cd File.join(@workdir, "ruby-#{@version}") do
      sh "./configure --prefix=/opt/puppet"
      sh "make"
      sh "make install"
    end
  end

  task :setup => :verify do
    cp File.join(SOURCES,@file), @workdir
    untar(File.join(@workdir, @file), @workdir)
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

  task :info do
    @name     = "ruby"
    @info     = @packages[@name]
    @file     = @info["file"]
    @version  = @info["version"]
    @url      = @info["url"]
    @md5      = @info["md5"]
  end
end
