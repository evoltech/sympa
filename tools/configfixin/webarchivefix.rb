#!/usr/bin/ruby
require "ftools"

if ARGV[0].nil? or !File.directory? ARGV[0]
  printf "Usage:\n%s /path/to/list/expl\n", $0
  exit 1
end

expl = ARGV[0]
Dir.chdir(expl)

Dir.foreach expl do |list|
  if list !~ /^\./ and File.directory? list
    config_file_name  = list + '/config'
    config_file = IO.read(config_file_name) if File.exist? config_file_name
    if config_file =~ /^web_archive\n\n/ # the file has a web_archive line
      puts list + ' has a web_archive line with no access type after it. fixing.'
      File.copy(config_file_name, config_file_name + '.bak')
      config_file.sub!(/^web_archive$/, "web_archive\naccess members\n")
      File.open(config_file_name, "w") do |file|
        file.puts config_file
      end
      elsif config_file !~ /^web_archive$/ # the file doesn't even have a web_archive line
      puts list + ' doesn\'t have a web_archive line. fixing.'
      File.open(config_file_name, "a") do |file|
        file.puts "\nweb_archive\naccess members\n" # add web_archive config to the end of the file
      end                                           # with an access line after it
    end
  end
end
