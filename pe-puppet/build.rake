# Task to build ruby from source and package as a .pkg file

namespace :'pe-puppet' do
  mkdir_p DATADIR
  task :build => [:clean, "pe-puppet.pre.list", :source] do
    sh "sudo mkdir -p #{CONFDIR}/puppet && sudo chown -R #{ENV['USER']} #{CONFDIR}"
    rubysitelib = %x{#{RUBY} -e 'puts RbConfig::CONFIG["sitelibdir"]'}.chomp
    #   Use install.rb to get files in place
    cd File.join(@workdir, "pe-puppet-#{@version}-#{@release}") do
      sh "#{RUBY} install.rb --configdir='#{CONFDIR}/puppet'"
      cp_r "ext", "#{DATADIR}/puppet/"
    end

    #   Copy conf files into place
    cd File.join(RAKE_ROOT, "pe-puppet") do
      ["auth.conf", "puppet.conf"].each {|c| cp c, "#{CONFDIR}/puppet"}
      cp "inspect.rb", "#{rubysitelib}/puppet/application/inspect.rb"
    end

    #   Remove extra files
    ["aix", "debian", "freebsd", "gentoo", "ips", "osx", "redhat", "solaris", "suse", "systemd", "vim", "windows"].each do |f|
      rm_r "#{DATADIR}/puppet/#{f}"
    end
  end
end
