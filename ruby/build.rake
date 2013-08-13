# Task to build ruby from source and package as a .pkg file

namespace :ruby do
  task :build => [:clean, "ruby.pre.list", :source] do
    cd File.join(@workdir, "ruby-#{@version}") do
      sh "./configure \
          --prefix=/opt/puppet \
          --enable-shared \
          --without-tcl \
          --without-tk \
          --without-fiddle \
          --with-yaml \
          --with-opt-dir=/opt/puppet \
          --disable-pthread"
      sh "make"
      sh "make install"
    end
  end
end
