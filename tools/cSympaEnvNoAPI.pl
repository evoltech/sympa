#!/usr/bin/perl 
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib";
use SympaDB;

use Data::Dumper;
use Getopt::Long;

my %options;
unless (&GetOptions(\%main::options, 
  'verbose+',
  'database=s',
  'user=s',
  'password=s',
  'server=s',
  'robot_subscriber=s',
  )) {
  &fatal_err("Unknown options.");
};

my ($server, $username, $password, $database);
my $sympa = new SympaDB ({
  'server' => $main::options{'server'} ? 
    $main::options{'server'} : 'localhost',
  'user' => $main::options{'user'} ? $main::options{'user'} : 'root',
  'password' => $main::options{'password'} ? $main::options{'password'} : '',
  'database' => $main::options{'database'} ? 
    $main::options{'database'} : 'sympa'});

my $sympa_expl_dir = '/home/sympa/expl/';
my @lists = <$sympa_expl_dir*>;

my $cas = '<?xml version="1.0" encoding="UTF-8" ?><custom_attributes></custom_attributes>';
my $ds = '2009-06-27 19:25:47';
my $vs = 'noconceal';
my $rs = $main::options{'robot_subscriber'} ?
  $main::options{'robot_subscriber'} : 'lists.dennisonwilliams.com';
my $res = 'mail';
my $cs = 'Mr. Evoltech';
my $ss = 1;
my $is = 0;

# Get all of the list names.
# Create and submit the sql for subscribing a random set of users to each 
# list.
foreach my $list_dir (@lists) {
  next if (! -d $list_dir);
  $list_dir =~ /\/([^\/]+)$/;
  my $list_name = $1;

  my $num_subscribers = rand_x_to_y(10, 100);
  print "Subscribing $num_subscribers users to $list_name.\n";
  while ($num_subscribers--) {
    subscribe_rand_user_to_list($list_name);
  }
}

sub subscribe_rand_user_to_list {
  use vars qw($sympa $cas $ds $vs $rs $cs $ss $is $res);
  my ($list) = @_;
  my $user = $sympa->get_random_user();
  $sympa->subscribe_user($list, $user->{email_user}, $cas, $rs, $ds, $vs, $rs, 
    $cs, $ss, $is);
}

sub rand_x_to_y {
  my ($min, $max) = @_;
  return -1 if ($min >= $max || $min <= 0);
  my $rand = 0;
  while ($rand < $min) {
    srand();
    $rand = int(rand($max));
  }
  return $rand;
}

