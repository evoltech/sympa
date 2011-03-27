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
    if config_file =~ /^info.anyone$/
      puts list + ' has info.open. changing to info anyone'
      File.copy(config_file_name, config_file_name + '.bak')
      config_file.sub!(/info.anyone/, "info anyone")
      File.open(config_file_name, "w") do |file|
        file.puts config_file
      end
    end
  end
end
