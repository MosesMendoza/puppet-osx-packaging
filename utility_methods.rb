# Utilities for managing files, etc
def get_temp
  `mktemp -d -t pkgXXXXXX`.strip
end

def workdir
  @workdir ||= get_temp
end

def untar(file, outdir=nil)
  c = "-C #{outdir}" if outdir
  sh "tar -xf #{file} #{c}"
end
