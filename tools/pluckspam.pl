#!/usr/bin/perl

##############################################
# pluckspam.pl - rhymes with what?
#     process spam complaints
#
# usage: cat <an aol spam complaint email> | perl pluckspam.pl
#
# Status
# 1) find list name - done
# 2) find user's email address - done
# 3) unsubscribe user - done
#   a) record complainer - done
# 4) record complaint against list - done
# 5) return error code. 0 means action required, >0 means action taken
#
################################################

use strict;

my ($re_list_header, $re_reminder_mailto, $re_reminder_subject, $re_welcome_subject, $re_welcome_email, $re_subscribe_subject, $re_spam_report_subject, $re_subject);
my ($line, $subject, $listmatch, $emailmatch);
my ($result_code, $remove_user_string, $complainer, $list);
my ($complaints, $log, $archivedir, $archivefile);
my (@sortedlines);
my ($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST);
my ($tempsubject, $result);

################################################

# configuration

my $debug = 0;

# filenames
$complaints = "/home/sympa/tools/data/spam_list_complaints";
$log = "/home/sympa/tools/data/spam_complaint_log";
$archivedir = '/var/spool/spamreports/';


# regular expressions

$re_list_header = qr/List-Post\:\s\<mailto\:([A-Z0-9._%-]+)@[A-Z0-9._%-]+\.[A-Z]{2,4}\>\s*$/i;
$re_reminder_subject = qr/^Subject\: subscription reminder: (.*)\s*$/i;
$re_welcome_subject = qr/^Subject\: Welcome (?:is|to|in) list (.*)\s*$/i;
$re_subscribe_subject = qr/^Subject\: auth (?:\w)* subscribe (.*)\s*$/i;

$re_reminder_mailto = qr/^\s*mailto:[A-Z0-9._%-]+\@[A-Z0-9._%-]+\.[A-Z]{2,4}\?subject\=sig\%20[A-Z0-9._%-]+\%20([A-Z0-9._%-]+\@[A-Z0-9._%-]+\.[A-Z]{2,4})\s*$/i;
$re_welcome_email = qr/^Your subscription email is ([A-Z0-9._%-]+\@[A-Z0-9._%-]+\.[A-Z]{2,4})\s*$/i;

$re_subject = qr/^Subject\:\s(.*)\s*$/i;

# don't use () in this regex to return a substring
$re_spam_report_subject = qr/^Subject\: .*Client TOS Notification\s*$/i;

################################################

# initialize some variables
$listmatch = 0;
$emailmatch = 0;
$complainer = "";
$list = "";
$subject = "";
$tempsubject = "";

################################################

# begin

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time);
$Month += 1;
$Month = '0' . $Month if length($Month) < 2;
$Day = '0' . $Day if length($Day) < 2;
$archivefile = "$archivedir$Month$Day-$$.eml";

open(LOG,">>$log")	or print STDOUT "**** Unable to open $log for append: $!\n" && die;
flock(LOG, 2) 		or print LOG "**** Unable to exclusive-write lock $log: $!";  # don't die

open(ARCHIVE,">$archivefile")	or print LOG "**** Unable to write $archivefile: $!\n" && die;

# read in email messaage
LINE: while(<STDIN>){

	print ARCHIVE $_;

	if ($listmatch + $emailmatch == 3) {
		print ARCHIVE "\n\n $0 FOUND BOTH USER AND LIST SO IT TRUNCATED THIS EMAIL";
		goto ENDINPUT;
	}

	if ($_ =~ /$re_subject/) {
		
		# this is subject header
		$tempsubject = $1;

		# quit if first subject header is not a spam report
		if (length($subject) == 0 && $_ !~ /$re_spam_report_subject/) {
			
			# probably not an actual complaint email
			$subject = $tempsubject;
			print LOG "**** Ignored AOL email: $subject\n";
			print ARCHIVE "\n\n $0 DETERMINED THIS IS AN AOL MESSAGE SO IT TRUNCATED THIS EMAIL\n";
			goto ENDINPUT;

		} else {

		# set subject header for logfile
		$subject = $tempsubject; 
		$tempsubject = "";

		}
	}
	
	# test for listname
	goto EMAIL if $listmatch == 1;
	if (
		$_ =~ /$re_list_header/ || 
		$_ =~ /$re_welcome_subject/ || 
		$_ =~ /$re_reminder_subject/ ||
		$_ =~ /$re_subscribe_subject/
		) {

		# reg expressions should reference list with $1
		$list = $1;
		$listmatch = 1;
	}

EMAIL: next LINE if $emailmatch == 2;
	# test for reminder email
	if ($_ =~ /$re_reminder_mailto/ || $_ =~ /$re_welcome_email/) {

		# reg expressions should reference email with $1
		$complainer = $1;
		$emailmatch = 2;
	}
}

close(ARCHIVE);


ENDINPUT: 

$subject = substr($subject, 0, 20);
print STDOUT "\nEmail: $complainer  List: $list  Subject: $subject\n" if $debug;

# listmatch = 1, emailmatch = 2
$result_code = eval($emailmatch + $listmatch);

for (($subject, $list, $complainer)) {
	s/^\s+//;
	s/\s+$//;
}

if ($result_code == 0) {
	if (length($subject) < 1 ) {
		logit("No email, list or subject found.");
	} else {
		logit("No email or list found.");
	}
}
elsif ($result_code == 1) {
	# found a list
	update_complaints($list);
	logit("Added complaint for $list.");
} 
elsif  ($result_code == 2) {
	# found a complainer but no list.
	# remove from all lists.
	$remove_user_string = "bash /home/sympa/tools/remove_user $complainer ALL";

	if ($result = system $remove_user_string) {
		logit("Removed $complainer from ALL lists.");
	}
	else {
		logit("hmm.. system call \'$remove_user_string\' exited with $result.");
	}
}
elsif ($result_code == 3) {
	# found both a complainer and a list
	$remove_user_string = "bash /home/sympa/tools/remove_user $complainer $list";

	if ($result = system $remove_user_string) {
		logit("Removed $complainer from $list.");
	}
	else {
		logit("hmm.. system call \'$remove_user_string\' exited with $result.");
	}
}

close(LOG);


################################################
# end program
################################################


################################################
# subroutines
################################################

################################################
sub logit() {
	
	# log return value for match: 0 none, 1 list, 2 user, 3 list and user
	print LOG "$Month$Day-$$: $result_code : $_[0] : $subject\n";
}
################################################


################################################
sub update_complaints {

    # subroutine accepts one list name as a parameter
    my $list = shift;
	
	for ($list) {
    	s/^\s+//;
    	s/\s+$//;
   	}
	
    my $count = 0;
    my ($line, @lines);

    # read complaint tally file
	if (-e $complaints) {
	    open(C, $complaints) 	or print LOG "**** Unable to open $complaints for reading: $!" && die;
		flock(C, 1)				or print LOG "**** Unable to shared-read lock $complaints: $!" && die;
	    while(<C>) {
	        push @lines, $_;
	    }
	    close(C);
	}

	# sort tally file
	@sortedlines = sort { $b <=> $a } @lines;

	# write complaints tally file
    open(COMPLAINTS, "> $complaints") or print LOG "**** Unable to open $complaints for writing: $!" && die;
	flock(COMPLAINTS, 2)		or print LOG "**** Unable to exclusive-write lock $complaints: $!" && die;
    foreach $line (@sortedlines) {
        if ($line =~ /^(\d+)\s$list\s*$/) {

            # get current tally
            $count = $1;

            # overwrite, with incremented tally
            print COMPLAINTS ++$count .  " " . $list . "\n";

        } else {
            # write unmodified line back into file
            print COMPLAINTS $line;
        }
    }
    if ($count < 1) {
        # did not find listname in tally file
        print COMPLAINTS ++$count .  " " . $list . "\n";
    }
    close(COMPLAINTS);
}
################################################
