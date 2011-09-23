#!/usr/bin/perl -w
# checkbanned.pl - script to check sympa database for banned users
# Matt Taggart <taggart@riseup.net> 2011-09

use strict;
use Getopt::Std;
$Getopt::Std::STANDARD_HELP_VERSION="true";

use vars qw($data $VERBOSE $opt_q
            $userfile $adminfile $listfile
            @userregex @adminregex @listregex
            @users @admins @lists
            $usersql $adminsql $listsql );

$data='/home/sympa/etc/banned';
$userfile="$data/users";
$adminfile="$data/admins";
$listfile="$data/lists";
# by default we print nice headers for the user
$VERBOSE='true';

getopts('q');

sub HELP_MESSAGE {
  print "Usage: checkbanned.pl [-q]\n";
  print "     -q  : quiet mode, don't print headers. useful for cronjobs or nagios\n";
}

if ($opt_q) {
   undef $VERBOSE;
}

if ( -r $userfile ) {
   # load the regexs, removing comment lines
   @userregex = grep(!/^#/, &loadarray("$userfile"));

   # load the list of user
   $usersql='mysql -N --batch --database=sympa --execute "select email_user from user_table"';
   @users = &loadarray("$usersql|");

   print "#### processing users ####\n" if $VERBOSE;
   foreach (@users) {
      my $regex;
      foreach $regex (@userregex) {
         print "pattern '$regex' matched user '$_'\n" if m/$regex/;
      }
   }
}

if ( -r $adminfile ) {
   # load the regexs, removing comment lines
   @adminregex = grep(!/^#/, &loadarray("$adminfile"));
   
   # load the list of admin/list pairs
   $adminsql=q(mysql -N --batch --database=sympa --execute "select user_admin, list_admin from admin_table, list_table where list_admin=list_table.name_list and list_table.status_list != 'closed'");
   @admins = &loadarray("$adminsql|");

   print "#### processing admins ####\n" if $VERBOSE;
   foreach (@admins) {
      my ($address, $list) = split /\t/,$_;
      $_ = $address;
      my $regex;
      foreach $regex (@adminregex) {
         print "pattern '$regex' matched admin '$address' of list '$list'\n" if m/$regex/;
      }
   }
}
if ( -r $listfile ) {
   # load the regexs, removing comment lines
   @listregex = grep(!/^#/, &loadarray("$listfile"));

   # load the list of lists
   $listsql=q(mysql -N --batch --database=sympa --execute "select name_list from list_table where status_list != 'closed'");
   @lists = &loadarray("$listsql|");

   print "#### processing lists ####\n" if $VERBOSE;
   foreach (@lists) {
      my $regex;
      foreach $regex (@listregex) {
         print "pattern '$regex' matched list '$_'\n" if m/$regex/;
      }
   }
}

# loads a file into an array
sub loadarray {
   my $file = shift(@_);
   my @regexs;
   open(FILE,"$file") or die "cannot open $file\n";
   while (<FILE>) {
      chomp;
      push @regexs,$_;
   }
   close(FILE);
   return @regexs;
}

