# Task to build ruby from source and package as a .pkg file

namespace :libyaml do
  task :build => [:clobber, "libyaml.pre.list", :source] do
    cd File.join(@workdir, "yaml-#{@version}") do
      sh "./configure \
          --prefix=/opt/puppet"
      sh "make"
      sh "make install"
    end
  end
end
