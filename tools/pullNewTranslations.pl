#!/usr/bin/perl
use strict;
use warnings;
use WWW::Mechanize;
use IO::Uncompress::Gunzip qw( gunzip $GunzipError );
use Getopt::Long;
use Data::Dumper;

my ($verbose, $help, $username, $password);

my $result = GetOptions (
	"username:s" => \$username,
	"password:s" => \$password,
  "verbose+"    => \$verbose,
  "help" => \$help
);

if ($help || !($username && $password)) {
  usage();
  exit();
}


my @langs = qw( ar bg br ca cs de el en es et eu fi fr gl hu id it ja ko la ml nb_NO nl oc pl pt_BR pt ro ru sv tr vi zh_CN zh_TW ); 
my @projects = qw( sympa web_help );

# Log in to pootle
# This fails with a 200
# This succeeds with a 302 and a Location http://pootle.sympa.org/accounts/login/
my $browser = my $mech = WWW::Mechanize->new();

# Disbale redirects
$browser->requests_redirectable([]);

$browser->get('http://pootle.sympa.org/accounts/login/');
$browser->field('username', $username);
$browser->field('password', $password);
my $response = $browser->submit();
if ($response->code() == 200) {
	print "Unable to log in with $username to http://pootle.sympa.org/accounts/login/\n";
	exit;
}

# re-enable redirects for the downloads
$browser->requests_redirectable(['GET']);

foreach my $project (@projects) {

	print "Making a directory for project $project...\n"
		if ($verbose && !-d $project);

	mkdir $project
		if (!-d $project);

	foreach my $lang (@langs) {
		my $file = $project .'/'. $lang .'.po';
		my $url = "http://pootle.sympa.org/$lang/$project/$project.po/download/";

		print "Getting language file $file from $url ...\n"
			if ($verbose);

		if ( ! open( FOUT, ">$file.gz" ) ) {
				die( "Could not create file $file: $!" );
		}

		my $response = $browser->get($url);

		print( FOUT $response->content() );

		close( FOUT );

		my $content;
	  my $status = gunzip "$file.gz" => $file
			or die "gunzip failed: $GunzipError\n";

		unlink "$file.gz";
	}
}

#sub response_redirect {
#  my($response, $ua, $h) = @_;
#
#  my $url;
#	return if ($response
#  if ($response->header('Location')) {
#
#    # This is an ugly fix, but to help keep us from ending up in the 
#    # redirection loop then we need to check against a possible 
#    # redirection location set in the check_host method.
#    if ($response->header('Location') eq $LOCATION) {
#      $LOCATION = 'matched';
#      return;
#    }
#
#}

sub usage {
print <<END;
$0 [options]
A tool for pulling the translation (po) files from sympa's pootle server
since there is no way to grab them all in bulk

--username <username>               : Account username for pootle.sympa.org
--password <password>               : Account password for pootle.sympa.org
--verbose                           : Turns out verbose logging of this script
--help                              : Print this help message
END
}
