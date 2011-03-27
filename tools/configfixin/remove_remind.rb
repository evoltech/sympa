#!/usr/bin/ruby
require "lib/replace_config"

replace_config do |list,config|
  if config =~ /^(remind_task .*)$/
    puts "removing remind_task from #{list}"
    config.sub(/^remind_task .*\n$/, "")
  else
    nil
  end
end

