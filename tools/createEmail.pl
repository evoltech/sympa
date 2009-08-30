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
  'robot_subscriber=s',
  )) {
  &fatal_err("Unknown options.");
};

die('We demand a domain to be defined in --robot_subscriber')
  if (!$main::options{'robot_subscriber'});

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

# Get all the lists and send them a random number of emails from a random 
# number of users.
foreach my $list_dir (@lists) {
  next if (! -d $list_dir);
  $list_dir =~ /\/([^\/]+)$/;
  my $list_name = $1;
  my $list = $list_name ."\@lists.dennisonwilliams.com";
  my $emails = $sympa->getUserEmailsByList(
    $list_name, $main::options{'robot_subscriber'});
  print "Sending emails to $list...\n" 
    if ($main::options{'verbose'});
  send_random_num_emails_from_random_users($list, $emails);
  exit;
}

sub send_random_num_emails_from_random_users {
  my ($list, $users) = @_;
  my $num_emails = rand_x_to_y(100, 100000);

  my $body = lori_ipsum(rand_x_to_y(100, 1000));
  while ($num_emails--) {
    my $user_index = rand_x_to_y(0, $#{$users});
    my $user = ${$users}[$user_index];
    my $email = Email::Simple->create(
      header => [
        To      => $list,
        From    => $user,
        Subject => lori_ipsum(6),
      ],
      body => $body
    );
    print "\tSending email from $user\n" 
      if ($main::options{'verbose'} > 1);

    sendmail($email);
  }
}

sub rand_x_to_y {
  my ($min, $max) = @_;
  my $rand = int(rand($max));
  print "rand: $rand\n"
    if ($main::options{'verbose'} > 2);
  return $rand;
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

