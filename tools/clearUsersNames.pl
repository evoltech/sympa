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

my $users = $sympa->getUsers();
foreach my $user (@$users) {
	if ($user->{name}) {
		print "Removing username in DB for ". $user->{email} ."\n"
			if $main::options{verbose};
		$sympa->clearUserName($user->{email});
	}
}
