#!/usr/bin/ruby
require 'fileutils'

#
# rebuildarchives.rb
#
# This is a little script to force the rebuilding of
# archives slowly... so that we can rebuild the archives
# without freaking out the system.
#
#

########### configuration #######################

$chunksize = 0      # how many to rebuild at a time, if zero, do them all
$sleeptime = 10     # seconds to sleep
$arcdir = "/home/sympa/arc"
$rebuild_spool = "/home/sympa/spool/outgoing"

#################################################

def waiting_for_spool_to_process
  Dir.glob("#{$rebuild_spool}/.rebuild*").any?
end

def archive_has_html(arc)
  dirglob = "#{$arcdir}/#{arc}/*"
  firstdir = Dir.glob(dirglob).first
  File.exist?("#{firstdir}/mail1.html")
end

def process_chunk(chunk)
  while waiting_for_spool_to_process
    #puts 'waiting for archives to rebuild. sleeping...'
    puts '.'
    sleep $sleeptime
  end
  chunk.each do |arcname|
#    if archive_has_html(arcname)
#      puts 'skipping %s...' % arcname
#    else
      puts "queued #{arcname}"
      FileUtils.touch "#{$rebuild_spool}/.rebuild.#{arcname}"
#    end
  end
  puts 'finished chunk'
end

archives = Dir.entries($arcdir) - ['.','..']
archives.sort! {|a,b|rand(3)-1}

if $chunksize == 0
  process_chunk archives
else
  count = archives.size
  chunks = count/$chunksize
  (0..chunks).each do |i|
    chunk_start = i * $chunksize
    chunk_end = chunk_start + ($chunksize-1)
    chunk = archives[chunk_start..chunk_end]
    process_chunk chunk
  end
end

puts "FINISHED"

