# Task to build ruby from source and package as a .pkg file

namespace :mcollective do
  task :build => [:clean, "mcollective.pre.list", :source] do
    rubysitelib = %x{#{RUBY} -e 'puts RbConfig::CONFIG["sitelibdir"]'}.chomp
    cd File.join(@workdir, "mcollective-#{@version}") do
      sh "make install"
    end

    # Because ruby ships with JSON we don't use the one vendored by
    # mcollective
    rm_r "#{rubysitelib}/mcollective/vendor/json"
    rm "#{rubysitelib}/mcollective/vendor/load_json.rb"
  end
end
