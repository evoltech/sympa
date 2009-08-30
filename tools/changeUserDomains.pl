#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Data::Dumper;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Getopt::Long;
use SympaDB;

my $dictionary = '/etc/dictionaries-common/words';
my %options;
unless (&GetOptions(\%main::options, 
  'verbose+',
  'database=s',
  'user=s',
  'password=s',
  'server=s',
  'target_domain=s',
  'destination_domain=s',
  )) {
  &fatal_err("Unknown options.");
};

die('We demand a target domain to be defined in --target_domain')
  if (!$main::options{'target_domain'});

die('We demand a destination domain to be defined in --destination_domain')
  if (!$main::options{'destination_domain'});

my ($server, $username, $password, $database);
my $sympa = new SympaDB ({
  'server' => $main::options{'server'} ? 
    $main::options{'server'} : 'localhost',
  'user' => $main::options{'user'} ? $main::options{'user'} : 'root',
  'password' => $main::options{'password'} ? $main::options{'password'} : '',
  'database' => $main::options{'database'} ? 
    $main::options{'database'} : 'sympa'});

# For each user with an addr in the target domain rewrite the addr to use
# the destination domain.
$sympa->rewriteUserEmailDomains(
  $main::options{'target_domain'}, $main::options{'destination_domain'});
