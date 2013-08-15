# Task to build ruby from source and package as a .pkg file

namespace "stomp" do
  task :build => [:clean, "stomp.pre.list", :source] do
    cd File.join(@workdir, "stomp-#{@version}") do
      rubysitelib = %x{#{RUBY} -e 'puts RbConfig::CONFIG["sitelibdir"]'}.chomp
      # Install files
      cp_r Dir["lib/*"], rubysitelib
      cp_r Dir["bin/*"], BINDIR

      # Permissions and shebang fixes
      ["catstomp", "stompcat"].each do |f|
        sh "chmod a+x #{BINDIR}/#{f} #{BINDIR}/#{f}"
        sh "sed -i -e '1s,^#!.*ruby$,#!#{BINDIR}/ruby,' #{BINDIR}/#{f}"
      end
    end
  end
end
