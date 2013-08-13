# Task to build ruby from source and package as a .pkg file

namespace "ruby-rgen" do
  task :build => [:clean, "ruby-rgen.pre.list", :source] do
    cd File.join(@workdir, "ruby-rgen-#{@version}") do
      rubysitelib = %x{#{RUBY} -e 'puts RbConfig::CONFIG["sitelibdir"]'}.chomp
      cp_r Dir["lib/*"], rubysitelib
    end
  end
end
