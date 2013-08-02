# Task to build ruby from source and package as a .pkg file

namespace :ruby do
  task :build => :setup do
  end

  task :setup => :verify do
    cp @file, @workdir
    untar(File.join(@workdir, @file), @workdir)
  end

  task :verify => :retrieve do
    unless @md5.to_sym == Digest::MD5.file(@file).hexdigest.to_sym
      fail "Sums don't match for #{@file}"
    end
  end

  task :retrieve => :info do
    rm_f @file
    sh "wget #{@url}"
  end

  task :info do
    @info     = @packages["ruby"]
    @file     = @info["file"]
    @version  = @info["version"]
    @url      = @info["url"]
    @md5      = @info["md5"]
  end

end