# Task to build ruby from source and package as a .pkg file

namespace :ruby do
  task :build => [:clobber, "ruby.pre.list", :source_setup] do
    cd File.join(@workdir, "ruby-#{@version}") do
      sh "./configure --prefix=/opt/puppet \
          --without-tcl \
          --without-tk \
          --without-fiddle \
          --disable-pthread"
      sh "make"
      sh "make install"
    end
  end
end
