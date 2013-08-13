# Task to build ruby from source and package as a .pkg file

namespace :facter do
  task :build => [:clobber, "facter.pre.list", :source] do
    cd File.join(@workdir, "facter-#{@version}") do
      sh "#{RUBY} install.rb --quick --no-rdoc"
    end
  end
end
