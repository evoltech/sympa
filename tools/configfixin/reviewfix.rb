#!/usr/bin/ruby
require "lib/replace_config"

replace_config do |list,config|
  if config =~ /^(review owner)$/
    puts "replacing 'review owner' with 'review owners' from #{list}"
    config.sub(/^review owner\s*$/, "review owners")
  else
    nil
  end
end

