#!/usr/bin/ruby
require "ftools"

if ARGV[0].nil? or !File.directory? ARGV[0]
  printf "Usage:\n%s /path/to/sympa/expl\n", $0
  exit 1
end

expl = ARGV[0]
Dir.chdir(expl)
Dir.foreach expl do |list|
  if list !~ /^\./ and File.directory? list
    config_file_name  = list + '/config'
    config_file = IO.read(config_file_name) if File.exist? config_file_name
    puts list + " doesn't have an owner" if (config_file !~ /(^owner$).+(^email .+@.+$)/m)
  end
end
