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

def erb(erbfile, outfile)
  require 'erb'
  template = File.read(erbfile)
  message  = ERB.new(template, nil, "-")
  output   = message.result(binding)
  File.open(outfile, 'w') { |f| f.write output }
  puts "Generated: #{outfile}"
end
