#!/usr/bin/ruby

require 'fileutils'
require 'iconv'

domain       = "lists.riseup.net"
home_dir     = "/home/sympa"
template_dir = "#{home_dir}/etc/web_tt2"
expl_dir     = "#{home_dir}/expl"
inc_dir      = "#{home_dir}/docroot/inc"
header_file  = "#{inc_dir}/header.html"
footer_file  = "#{inc_dir}/footer.html"
directory_dir  = "#{home_dir}/docroot/directory"
directory_file = "#{template_dir}/custom_list_directory.tt2"

##############################################################
# FUNCTIONS

def load_topics( file )
  topics = []
  topic = nil
  open( file ).each do |line|
    if line =~ /^title (.*)$/
      topics << [topic, $1] if topic
    elsif line =~ /xother/
      topic = nil # skip xother
    elsif line =~ /^(\w*)\s*$/
      topic = $1
    end
  end
  topics
end

def load_config(file)
  conf = {}
  open(file).each do |line|
    if line =~ /^(status|visibility|topics|subject|info)\s*(.*)\s*$/u
      option, value = $1.to_sym, $2
      conf[option] = value unless option == :visibility and conf[:visibility] # don't reset visibility if it was already set. in some config files, it is first set for the whole list, and then later in the file it includes the visibility of list owners/moderators   
    end
  end
  conf[:topics] = (conf[:topics]||'').split(/[\s,]/).compact.uniq
  conf[:visibility] ||= 'anyone'
  conf[:info] ||= 'open'
  conf
end

def load_lists(dir)
  listsbytopic = {}
  lists = Dir.entries(dir) - ['.','..']
  lists.each do |list|
    next unless File.exist? "#{dir}/#{list}/config"
    conf = load_config("#{dir}/#{list}/config")
    next unless conf[:status] == 'open'
    yield list, conf
    conf[:topics].each do |topic|
      listsbytopic[topic] ||= []
      listsbytopic[topic] << [list, conf]
    end
  end
  listsbytopic
end

# we don't know if string is already unicode, or something else
def convert_string_to_utf8(string)
  begin
    # string is probably already unicode if it parses at UTF-8
    return Iconv.iconv('UTF-8', 'UTF-8', string)
  rescue
    # try ISO-8859-15, then give up.
    return Iconv.iconv( 'UTF-8', 'ISO-8859-15', string ) rescue string
  end
end

##############################################################
# MAIN

visiblecount = 0
hiddencount = 0

listsbytopic = load_lists(expl_dir) do |list, conf|
  if conf[:visibility] == 'anyone'
    visiblecount += 1
  else
    hiddencount += 1
  end
end

header = IO.read(header_file)
footer = IO.read(footer_file)

topics = load_topics("#{home_dir}/etc/topics.conf")
topics.each do |topic|
  topic_name, topic_title = topic
  topic_dir = "#{directory_dir}/#{topic_name}/"
  topic_file = "#{directory_dir}/#{topic_name}/index.html"

  listsbytopic[topic_name] ||= []
  
  html = header
  html += "<blockquote><div><a href='/www'>Home</a> &raquo; <a href='/directory/#{topic_name}/'>#{topic_title}</a></div>\n\n"
  
  listsbytopic[topic_name].sort.each do |list|
    listname, listdata = list
    next unless listdata[:visibility] == 'anyone' and (listdata[:info] == 'open' or listdata[:info] == 'anyone') # having info set to 'open' or 'anyone' seem to be equivalent, so changing this so it treats them as the same. These options might get redone, but should be a fine fix for now.
    subject = convert_string_to_utf8(listdata[:subject])
    html += "<p><a href='/www/info/#{listname}'>#{listname}</a> #{subject}</p>\n\n"
  end
  html += footer
  
  FileUtils.mkdir_p(topic_dir)
  open(topic_file,'w') do |f|
    f << html
  end
end

topics.sort! do |a,b|
  a[0] <=> b[0]
end

html = "<table id='listdirectory'><tr>\n"
html += "<td><ul class='plainlist'>\n"
rows = topics.size/3
i = 1
topics.each do |topic|
  topic_name, topic_title = topic
  html += "<li><a href='/directory/%s/'>%s (%s)</a></li>\n" % [topic_name, topic_title, listsbytopic[topic_name].size]
  html += "</ul></td><td><ul class='plainlist'>\n" if i%rows==0
  i += 1
end
html += "</tr></table></blockquote>\n"

open(directory_file,'w') do |f|
  f << html
end
