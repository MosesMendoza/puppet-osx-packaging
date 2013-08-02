RAKE_ROOT = File.dirname(__FILE__)

load File.join(RAKE_ROOT, "tasks", "setup.rake")

# Utilities for managing files, etc
def get_temp
  `mktemp -d -t pkgXXXXXX`.strip
end

def workdir
  @workdir ||= get_temp
end

desc "Build All"
task :all => :ruby

desc "Build ruby"
task :ruby => :setup do
  Rake::Task["build:ruby"].invoke
end

desc "Setup work dir"
task :setup do
  mkdir_p workdir
end

