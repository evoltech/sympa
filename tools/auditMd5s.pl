#!/usr/bin/perl
# Get your api key here: http://www.md5crack.com/api

#evoltech@sympa:~/sympa/tools$ ./auditMd5s.pl --user sympa --password 3upmicM2V3ANrez --apikey e15910meow6ac1a2fb062 --verbose
#listmaster@foo.com => ecb3b65ec98d38942b4182becafa7bd8
#        The MD5 hash could not be cracked.
#root@localhost.localdomain => ecb3b65ec98d38942b4182becafa7bd8
#        The MD5 hash could not be cracked.
#test1@meow.com => ecb3b65ec98d38942b4182becafa7bd8
#        The MD5 hash could not be cracked.
#test2@foo.com => ecb3b65ec98d38942b4182becafa7bd8
#        The MD5 hash could not be cracked.
#test2@meow.com => ecb3b65ec98d38942b4182becafa7bd8
#        The MD5 hash could not be cracked.
#test3@meow.com => ecb3b65ec98d38942b4182becafa7bd8
#        The MD5 hash could not be cracked.
#test5@foo.com => ecb3b65ec98d38942b4182becafa7bd8
#        The MD5 hash could not be cracked.
#test6@foo.com => ecb3b65ec98d38942b4182becafa7bd8
#        The MD5 hash could not be cracked.

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Data::Dumper;
use Getopt::Long;
use LWP::Simple;
use JSON;
use SympaDB;

my %options;
unless (&GetOptions(\%main::options, 
  'verbose+',
  'database=s',
  'user=s',
  'password=s',
  'server=s',
  'apikey=s',
  )) {
  &fatal_err("Unknown options.");
};

die "You must specify --apikey your_md5crack.com_api_key"
	unless $main::options{'apikey'};

my ($server, $username, $password, $database);
my $sympa = new SympaDB ({
  'server' => $main::options{'server'} ? 
    $main::options{'server'} : 'localhost',
  'username' => $main::options{'user'} ? $main::options{'user'} : 'root',
  'password' => $main::options{'password'} ? $main::options{'password'} : '',
  'database' => $main::options{'database'} ? 
    $main::options{'database'} : 'sympa'});


eval {
	$sympa->init();
	$sympa->{selectUsersSTH}->execute(); 
};
if ($@) {
	 die "Could not get a user list from the DB: $! $@\n";
}

my @codes = (
	"An invalid API Key was used.",
	"All parameters must be used (API Type, API Key, Phrase).",
	"An invalid API Type was selected.",
	"You have reached your query limit.",
	"The API Key used is not associated with this domain.",
	"The MD5 hash was generated.",
	"The MD5 hash was cracked.",
	"The MD5 hash could not be cracked.",
);

my $json = JSON->new->allow_nonref;
while (my $user = 
	$sympa->{selectUsersSTH}->fetchrow_hashref('NAME_lc')) {
	next unless $user->{'password_user'} !~ /^init/;
	print $user->{email_user} ." => ". $user->{password_user} ."\n"
		if $main::options{'verbose'};

	my $url = "http://api.md5crack.com/crack/". 
		$main::options{'apikey'} .'/'.
		#This is the has for "pass"
		#"1a1dc91c907325c69271ddf0c944bc72";
		$user->{password_user};

	my $response = $json->decode(get($url));	

	if (!$response->{parsed} && $main::options{'verbose'}) {
		print "\t". $response->{response} ."\n";
	} elsif ($response->{parsed}) {
		print $user->{email_user} ." => ". $response->{parsed} ."\n";
	}
}
