#!/usr/bin/perl -w
# checkbanned.pl - script to check sympa database for banned users
# Matt Taggart <taggart@riseup.net> 2011-09

$data='/home/sympa/etc/banned';
$userfile="$data/users";
$adminfile="$data/admins";
$listfile="$data/lists";
# by default we print nice headers for the user
$VERBOSE='true';

# usage stuff

if ( -r $userfile ) {
   # load the regexs, removing comment lines
   @userregex = grep(!/^#/, &loadarray("$userfile"));

   # load the list of user
   $usersql='mysql -N --batch --database=sympa --execute "select email_user from user_table"';
   @users = &loadarray("$usersql|");

   print "#### processing users ####\n" if $VERBOSE;
   foreach (@users) {
      foreach $regex (@userregex) {
         print "pattern '$regex' matched user '$_'\n" if m/$regex/;
      }
   }
}

if ( -r $adminfile ) {
   # load the regexs, removing comment lines
   @adminregex = grep(!/^#/, &loadarray("$adminfile"));
   
   # load the list of admin/list pairs
   $adminsql='mysql -N --batch --database=sympa --execute "select user_admin, list_admin from admin_table, list_table where list_admin=list_table.name_list and list_table.status_list=\'open\'"';
   @admins = &loadarray("$adminsql|");

   print "#### processing admins ####\n" if $VERBOSE;
   foreach (@admins) {
      ($address, $list) = split /\t/,$_;
      $_ = $address;
      foreach $regex (@adminregex) {
         print "pattern '$regex' matched admin '$address' of list '$list'\n" if m/$regex/;
      }
   }
}
if ( -r $listfile ) {
   # load the regexs, removing comment lines
   @listregex = grep(!/^#/, &loadarray("$listfile"));

   # load the list of lists
   $listsql='mysql -N --batch --database=sympa --execute "select name_list from list_table where status_list=\'open\'"';
   @lists = &loadarray("$listsql|");

   print "#### processing lists ####\n" if $VERBOSE;
   foreach (@lists) {
      foreach $regex (@listregex) {
         #print "foo $_\n";
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

