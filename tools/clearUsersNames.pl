#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Data::Dumper;
use Getopt::Long;
use SympaDB;

my %options;
unless (&GetOptions(\%main::options, 
  'verbose+',
  'database=s',
  'user=s',
  'password=s',
  'server=s',
  )) {
  &fatal_err("Unknown options.");
};

my ($server, $username, $password, $database);
my $sympa = new SympaDB ({
  'server' => $main::options{'server'} ? 
    $main::options{'server'} : 'localhost',
  'username' => $main::options{'user'} ? $main::options{'user'} : 'root',
  'password' => $main::options{'password'} ? $main::options{'password'} : '',
  'database' => $main::options{'database'} ? 
    $main::options{'database'} : 'sympa'});

$sympa->init();

eval {
	$sympa->{selectUsersSTH}->execute(); 
};
if ($@) {
	 die "Could not get a user list from the user_table: $!\n";
}

while (my $user = 
	$sympa->{selectUsersSTH}->fetchrow_hashref('NAME_lc')) {
	if ($user->{gecos_user}) {
		print "Removing users name from user_table DB for ". $user->{email_user} ."\n"
			if $main::options{verbose};
		$sympa->clearUserNameFromUser($user->{email_user});
	}
}

eval {
	$sympa->{selectSubscribersSTH}->execute(); 
};
if ($@) {
	 die "Could not get a user list from the subscriber_table: $!\n";
}

while (my $subscriber = 
	$sympa->{selectSubscribersSTH}->fetchrow_hashref('NAME_lc')) {
	if ($subscriber->{comment_subscriber}) {
		print "Removing users name from subscriber_table DB for ". $subscriber->{user_subscriber} ."\n"
			if $main::options{verbose};
		$sympa->clearUserNameFromSubscriber($subscriber->{user_subscriber});
	}
}
