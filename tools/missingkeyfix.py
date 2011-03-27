#!/usr/bin/python

import sys,os,glob
import re

usage = "usage: %s <listdir>" %  os.path.basename(sys.argv[0])

if len(sys.argv) < 2:
    print usage
    sys.exit(-1)

listdir = sys.argv[1]
buf = ""
needmail = 0
hasmail = 0
not_ok = 0

empty = re.compile(r"^[\t \n]+$")
ismail = re.compile(r".*email .*@.")
param = re.compile(r"^(owner|editor) *$")

for listconfig in glob.glob(listdir + '/config'):
    print "file %s" % listconfig
    buf = ""
    needmail = 0
    hasmail = 0
    not_ok = 0

    # Create a file to work with, will be later renamed as the config
    # if there were changes that were made
    new_config_name = "%s_tmp" % listconfig
    new_config = open(new_config_name, 'w')
    
    # Start stepping through the config file
    #for line in xreadlines.xreadlines(open(listconfig)):
    fh = open(listconfig)
    for line in fh:
	buf = buf + line

	if empty.match(line):
	    if needmail == 1 and hasmail == 0:
		sys.stderr.write("Not ok1: %s \n--------\n%s---------\n" % (listconfig, buf))
		not_ok = 1
	    else:
		new_config.write(buf)
		
	    # init for next paragraph
	    needmail = 0
	    hasmail = 0
	    buf = ""
		
	elif param.match(line):
	    needmail = 1 # need to have an email section somewhere
		
	elif ismail.match(line):
	    hasmail = 1
      
	else:
	    # nothing special
	    pass
	    
    if needmail == 1 and hasmail == 0:
	sys.stderr.write("Not ok2: %s \n--------\n%s---------\n"  % (listconfig, buf))
	not_ok = 1
    else:
	new_config.write(buf)
	
    new_config.flush()
    new_config.close()
    
    # If there was a problem, so we need to take the corrected config file
    # and put it in the right place after backing up the existing one
    if not_ok:
	# Backup the config file, just in case
	os.system('cp %s %s_bak.keyfix' % (listconfig, listconfig))
	# Rename the temporary file to the perm config
	os.rename(new_config_name,listconfig)

    # Everything was fine with the config file, clean up and go home
    else:
	os.remove(new_config_name)
