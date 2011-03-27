#!/usr/bin/ruby
require "ftools"

if ARGV[0].nil? or !File.directory? ARGV[0]
  printf "Usage:\n#{$0} /path/to/sympa/expl\n ..or.. \n#{$0} /path/to/list/dir\n"
  exit 1
end

trap("INT") {puts '<interrupted>'; exit 0}

def process_list_dir(list, file, *args)
  debug = args.include? :debug
  config_file_name  = list + '/' + file
  config_file = IO.read(config_file_name) if File.exist? config_file_name
  new_config = yield(list, config_file)
  if new_config
    if debug
      puts '================================================================'
      puts list
      puts new_config
    else
      File.copy(config_file_name, config_file_name + '.bak')
      File.open(config_file_name, "w") do |f|
        f.puts new_config
      end
      puts "replacing #{file} for #{list}"
    end
  elsif debug
    puts "skipping #{list}"
  end
end

def replace_expl_file(file, *args, &block)
  expl = ARGV[0]
  if expl =~ /expl/ and expl !~ /expl\/?$/ and File.exists?("#{expl}/config")
    # list directory was given
    Dir.chdir(File.dirname(expl))
	process_list_dir(File.basename(expl), file, *args, &block)
  else
    Dir.chdir(expl)
    puts 'loading expl dir...'
    Dir.foreach expl do |list_dir|
	  next unless list_dir !~ /^\./ and File.directory? list_dir
	  process_list_dir(list_dir, file, *args, &block)
	end
  end
end

def replace_config(*args, &block)
  replace_expl_file('config', *args, &block)
end

def replace_info(*args, &block)
  replace_expl_file('info', *args, &block)
end

def replace_homepage(*args, &block)
  replace_expl_file('homepage', *args, &block)
end


##################################################
##
## EXAMPLE
##
#
# require 'replace_config'
#
# replace_config do |list,config|
#   if config =~ /^info.anyone$/
#     return config.sub(/info.anyone/, "info anyone")
#   end
# end
#