#!/usr/bin/perl -w
use strict;
use Digest::MD5;
use Data::Dumper;

die("feed me a pass!") unless $#ARGV == 0;

my $pass = shift @ARGV;

print $pass .":". md5_fingerprint($pass) ."\n";

## input a string
## output md5 digest
sub md5_fingerprint {

    my $input_string = shift;
    return undef unless (defined $input_string);
    chomp $input_string;

    my $digestmd5 = new Digest::MD5;
    $digestmd5->reset;
    $digestmd5->add($input_string);
    return (unpack("H*", $digestmd5->digest));
}

