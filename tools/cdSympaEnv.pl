#!/usr/bin/perl
# This utility can be used to create or destroy a sympa environment.  It was 
# developed against the sympa-6.x code base (may work against 5.x as well).
# It is assumed that the created environment will consist of a number of users
# who are subscribed to a number of lists.
#
# Setting up an environment can be done like:
# cdSympaEnv.pl --setup=10000 --add_users=1000000 --domain=testdomain.com
# This will setup an environment with 10000 lists and 1000000 users with the 
# email addr <random_user_string>#testdomain.com. Each list will have a random
# set of 10 - 100 users subscribed to it.
#
# Tearing down the environment can be done like this:
# cdSympaEnv.pl --teardown --delete_users --domain=testdomain.com
# Which will remove all lists from a system, and delete all the users with the
# domain testdomain.com.
#
# It should be noted that in it's default configuration sympa stores info for lists
# on the filesystem, so attempting to create or delete a large number of lists 
# could take a long time.
$ENV{'PATH'} = '';

## Load Sympa.conf
use strict;
use lib '/home/sympa/share/sympa/lib';
use List;
use Conf;
use Getopt::Long;
use Log;
use Auth;
use admin;
use Data::Dumper;
my $dictionary = '/etc/dictionaries-common/words';
my $dbh;

unless (Conf::load('/home/sympa/etc/sympa.conf')) {
   print STDERR gettext("The configuration file /home/sympa/etc/sympa.conf contains errors.\n");
   exit(1);
}

## Check options
my %options;
unless (&GetOptions(\%main::options, 
  'debug|d', 
  'foreground', 
  'domain|d=s',
  'delete_users',
  'add_users:i',
  'log_level=s',
  'verbose+',
  'setup:i', 'teardown'
  )) {
  &fatal_err("Unknown options.");
}

init();
# Set up a list.
#my $list = add_a_random_list();
#print Dumper($list->{'list'}->get_default_user_options()) ."\n";
#print Dumper($list) ."\n";
#exit;

if (defined($main::options{'setup'})) {
  setup();
}
elsif (defined($main::options{'teardown'})) {
  teardown();
}


exit;

sub teardown {
  print "Going to delete lists.\n" 
    if ($main::options{'verbose'});

  # Get a list of all lists then delete them.
  my $all_lists = &List::get_lists('*');
  foreach my $list (@{$all_lists}) {
    $list->purge();
    print  "\tRemoved list ". $list->{'name'} ."\n"
      if ($main::options{'verbose'} > 1);
  }
  
  # Get a list of all users then delete them (do not delete the list admins) 
  print "Finished cleaning up installation.\n";
}

sub setup {
  print "Going to add lists.\n" 
    if ($main::options{'verbose'});

  # The return here is an array of values returned from create_list_old
  # which returns a hash ref containing two values 'aliases' and 'list'.
  # We are interested in 'list'.
  my @added_lists  = add_some_random_lists();
  foreach my $list (@added_lists) {
    $list = $list->{'list'}; 
    my $result = add_some_random_users_to_list($list);
    print "Added $result users to ". $list->{'name'} .".\n"
      if ($main::options{'verbose'});
  }

  print "Finished adding lists.\n";
}

sub init {
  use vars qw($dbh);
  if (!defined($main::options{'domain'})) {
    die('A domain must be defined with --domain|-d.');
  }

  if (!defined($main::options{'setup'}) &&
    !defined($main::options{'teardown'})) {
    die('Either --setup[=<number_of_lists_to_create>] or --teardown should be set');
  }

  if ($main::options{'debug'}) {
    $main::options{'foreground'} = 1;
    $main::options{'log_to_stderr'} = 1;
    print STDERR "debug is on\n";
    $main::options{'log_level'} = 3 unless ($main::options{'log_level'});
  }

  $main::options{'verbose'} |= 0;

  ## We keep trying to connect if this is the first attempt
  unless ( $dbh = &SQLSource::connect(\%Conf::Conf, 
    {'keep_trying'=>1, 'warn' => 1})) {
    die('Could not establish a database connection.');
  }
  do_log('debug3','Connected to Database %s',$Conf::Conf{'db_name'});

  ## Check databse connectivity
  unless (&List::check_db_connect()) {
      &fatal_err('Database %s defined in sympa.conf has not the right structure or is unreachable.', $Conf{'db_name'});
  }

  # setting log_level using conf unless it is set by calling option
  if ($main::options{'log_level'}) {
      &Log::set_log_level($main::options{'log_level'});
      do_log('info', "Configuration file read, log level set using options : $main::options{'log_level'}"); 
  }else{
      &Log::set_log_level($Conf{'log_level'});
      do_log('info', "Configuration file read, default log level $Conf{'log_level'}"); 
  }

  # Delete users if asked to.
  if (defined($main::options{'delete_users'})) {
    rm_all_users_by_domain();
  }

  # Add users if asked to.
  if (defined($main::options{'add_users'})) {
    add_some_random_users();
  }
}

# I think the function we are looking for is List::add_user()
# We need to send it a data structure as described in add_user.  I think 
# this is directly the fields from user_table.  This is done in 
# sympasoap.pm::add()
sub add_some_random_users_to_list {
  my ($list) = @_;
  my $num_users = rand_x_to_y(10, 100);
  my $defaults = $list->get_default_user_options();
  my $return = 0;

  while ($num_users--) {
    my $user = get_random_user();
    my $u;
    %{$u} = %{$defaults};
    $u->{'email'} = $user->{'email_user'};
    $u->{'gecos'} = $user->{'gecos_user'}; 
    $u->{'date'} = $u->{'update_date'} = time;
    # keys we need in our hashref for each user: email, password
    # NOTE: This may output duplicate key messages from the DB because
    # we may try to add the same user twice.  This is by design.
    if (!$list->add_user($u)) {
      print "Unable to add user: ". $u->{'email'} ."\n" 
        if($main::options{'verbose'});
    }
    else {
      print "Added ". $u->{'email'} ." to ". $list->{'name'} ."\n"
        if($main::options{'verbose'});
      $return++;
    }
  }
  return $return;
}

#@todo update to use riseup's #'s
sub add_some_random_lists {
  my $num_lists;

  $num_lists = ($main::options{'setup'} =~ /^[1-9]\d*$/) ? 
    $main::options{'setup'} : rand_x_to_y(1, 10);

  my @lists;
  while ($num_lists-- >= 0) {
    $lists[++$#lists] = add_a_random_list();
  }
  return @lists;
}

sub add_a_random_list {
  my $parameters;
  my $subject = lori_ipsum(3);
  $subject =~ s/'//g;
  my $description = lori_ipsum(80);
  $description =~ s/'//g;
  my $topics = lori_ipsum(5);
  $topics =~ s/'//g;
  $topics =~ s/\s+/,/g;

  $parameters->{'listname'} = rand_list_name();
  $parameters->{'subject'} = $subject;
  $parameters->{'owner'} = get_random_owner();
  $parameters->{'description'} = $description;
  $parameters->{'topics'} = $topics;

  # Owner info is still not getting set, and no error is getting raised.
  # This results in a mail getting sent out with the following message:
  # "No owner is defined for list ivacptfdf8apcwy30q5250."
  # I amnot sure where this message is getting sent from.  I believe this
  # is happening when the list gets written to config in 
  # admin::create_list_old().  In checking the config file though the owner
  # section does appear to be getting written, but it is not loaded into the
  # hash on list creation.  Why?  
  # It should be noted that the data in the config file is correctly getting
  # loaded in sympa.fcgi.  It should also be noted that this value is not
  # correctly populated in a supposedly valid list????  Is this a bug?
  # In fact emails still come through to subscribers.
  my $resul = &admin::create_list_old(
    $parameters, 'private_working_group',$Conf{'domain'},"command_line");
  unless(defined $resul) {
    printf('unable to create list %s@%s from %s'.".\n", 
      $parameters->{'listname'}, $Conf{'domain'}, 'command_line');
    &Log::do_log('err', 'unable to create list %s@%s from %s ', 
      $parameters->{'listname'}, $Conf{'domain'}, 'command_line');
    exit;
  }
  return $resul;
}

# Get and return a random user from the sympa db in the format needed for
# admin::create_list_old()
sub get_random_owner {
  my @owner;
  my $user =  get_random_user();
  push @owner, { 'email' => $user->{'email_user'} };
  return \@owner;
}

# Get a random user from the sympa setup.
# We should 
sub get_random_user {
  use vars qw($dbh);
  my $statement = 'SELECT * from user_table ORDER BY RAND() LIMIT 1';

  my $sth;
  unless ($sth = $dbh->prepare($statement)) {
    do_log('err','Unable to prepare SQL statement : %s', $dbh->errstr);
    return undef;
  }

  unless ($sth->execute) {
    do_log('err','Unable to execute SQL statement "%s" : %s', 
      $statement, $dbh->errstr);
    return undef;
  }

  my $user = $sth->fetchrow_hashref('NAME_lc');
  return $user;
}


sub print_users_by_list_name {
  my ($list_name) = @_;
  my $list = new List ($list_name, $Conf{'domain'});
  my $user = $list->get_first_user();
  do {
    print $user->{'email'} ."\n";
  } while ($user = $list->get_next_user());
}

sub dump_all_lists {
  my $all_lists = &List::get_lists('*');
  foreach my $list (@$all_lists) {
    printf STDERR "Attempting to dump a list\n";
    unless ($list->dump()) {
      printf STDERR "Could not dump list(s)\n";
    }
  }
}

# We will create a random num of users between 10 and 100, unless an
# explicit number is defined.  Each account will be some random 8 
# character user name followed by $main::options{'domain'}.
sub add_some_random_users {
  my $num_users = ($main::options{'add_users'} =~ /^[1-9]\d*$/) ?
    $main::options{'add_users'} : rand_x_to_y(10, 100);

  while ($num_users-- >= 0) {
    my $user;
    # Username and pass will be the same.
    my $username = rand_user_name();
    $user->{'email'} = $username .'@'. $main::options{'domain'};
    $user->{'password'} = $username;
    &List::add_user_db($user);
  }
}

# We remove all users by domain, because there could be some users whose
# accounts exist outside of the test domain to facilitate testing.
sub rm_all_users_by_domain {
  # Get all users by domain.
  my @users;

  ## Check database connection
  die ('Unable to contact the database when trying to get a list of '.
    'all users')
    unless ($dbh and $dbh->ping);

  my $statement = 
    sprintf ('SELECT email_user FROM user_table where email_user like "%%%s"', 
      $main::options{'domain'});

  print 'rm_all_users_by_domain(), Gunna get a list of users from the '.
    "results of: $statement \n"
    if ($main::options{'verbose'} > 1);

  my $sth = $dbh->prepare($statement);
  die('Unable to prepare SQL statement "'. $statement.'" : '. $dbh->errstr)
    unless ($sth);

  die('Unable to execute SQL statement "'. $statement .'" : '. $dbh->errstr)
    unless ($sth->execute);

  while (my $email = ($sth->fetchrow_array)[0]) {
    push @users, $email;
  }

  $sth->finish();

  # Delete all users.
  &List::delete_user_db(@users);
}

sub rand_x_to_y {
  use vars qw($logger);
  my ($min, $max)= @_;
  return -1 if ($min >= $max || $min <= 0);
  my $rand = 0;
  while ($rand < $min) {
    srand();
    $rand = int(rand($max));
  }
  return $rand;
}

sub rand_user_name {
  return rand_list_name();
}

sub rand_list_name {
  my $length = 20;
  my @letters = 'a'..'z';
  my @letters_numbers = 0..9;
  push (@letters_numbers, @letters);
  my $string = $letters[int(rand($#letters))];
  do {
    $string .= $letters_numbers[int(rand($#letters_numbers))];
  } while ($length--);
  return $string;
}

sub lori_ipsum {
  use vars qw($dictionary);
  my ($count) = @_;
  my (@words, $line);
  while ($#words < $count) {
    open DATA, $dictionary;
    rand($.) < 1 && ($line=$_) while <DATA>;
    close DATA;
    chomp $line;
    push(@words, $line);
  }
  return join(' ', @words);
}

