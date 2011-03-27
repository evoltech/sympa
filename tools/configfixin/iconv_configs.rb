#!/usr/bin/ruby

require "lib/replace_config"
require 'iconv'

# we don't know if string is already unicode, or something else
def convert_string_to_utf8(string)
  begin
    # string is probably already unicode if it parses at UTF-8
    Iconv.iconv('UTF-8', 'UTF-8', string)
    return false
  rescue
    # try ISO-8859-15, then give up.
    begin
      return Iconv.iconv( 'UTF-8', 'ISO-8859-15', string )
    rescue
      return false
    end
  end
  return false
end

replace_config do |list,config|
  convert_string_to_utf8(config)
end
