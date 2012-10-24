#!/usr/bin/perl

use YAML qw(LoadFile);
use Hash::Util qw(lock_hash);
use Template;
use Getopt::Long;

use strict;

## Check options
my %options;
unless (&GetOptions(\%main::options, 
  'setup', 'teardown', 'list_data:s', 'help'
  )) {
  die("Unknown options.\n\n".help());
}

use constant {
  LIST_DEF => "./list_definition.xml.tt2",
  LISTS_YAML => "./lists.yml",
  TMP_XML => "/tmp/listdef.xml",
  SYMPA_PATH => "/home/sympa/bin/sympa.pl",
  LIST_DATA => $main::options{'list_data'} || "/home/sympa/list_data"
};

check_files() && die("Missing required files. Exiting.");

if (defined($main::options{'help'})) {
  help();
}elsif (defined($main::options{'refresh'})) {
  teardown();
  setup();
}
elsif (defined($main::options{'teardown'})) {
  teardown();
}elsif (defined($main::options{'setup'})) {
  setup();
}

sub teardown {
  print "Going to delete lists.\n";

  # Get a list of all lists then delete them.
  # for some reason $all_lists is getting populated with a reference to an empty array
  # even though get_lists is returning a reference to a populated array
  # not sure if something is destroying the objects after get_lists returns or what? 
  # my $all_lists = List::get_lists('*');
  # so, use an alternate, though inferior, means to get the lists
  my $listdata = LIST_DATA;
  my @all_lists = `/bin/ls $listdata`;
  foreach my $list (@all_lists) {
    chomp($list);
    my $cmd = SYMPA_PATH." --purge_list=$list\@foo.com";
    print `$cmd`; 
    my $sync_cmd = SYMPA_PATH." --sync_list_db --list=$list\@foo.com";
    print `$sync_cmd`;
  }

  print "Finished cleaning up installation.\n";
}

sub setup {
  my $yaml_data = LoadFile(LISTS_YAML);
  my $total_lists = 0;
  my %defaults = %{$yaml_data->{'defaults'}};
  my $tt = Template->new({RELATIVE => 1});
  my $subscriber_cache = subscriber_cache();
  my @customs;

  lock_hash(%defaults); 

  if ($yaml_data->{'total_subscribers'}) {
    $subscriber_cache->($yaml_data->{'total_subscribers'}, 1);
  }

  if ($yaml_data->{'custom_order'}) {
    unless (ref($yaml_data->{'custom_order'}) eq "ARRAY") {
      die("The custom_order key in the lists.yml file needs to be an array.\n");
    }
    @customs = @{$yaml_data->{'custom_order'}};
  }else {
    @customs = keys %{$yaml_data->{'custom_configs'}};
  }
  foreach my $custom (@customs) {
    unless ($yaml_data->{'custom_configs'}->{$custom}->{'count'} > 0) {
      die "The 'count' key is required for custom configs. Missing count for $custom.\n";
    }
    my %defaults_copy = %defaults;
    foreach my $k ('owners', 'moderators') {
      $defaults_copy{$k} = [@{$defaults{$k}}] if (ref($defaults{$k}) eq "ARRAY");
    }
    my $created = create_lists(
                    \%defaults_copy,
                    $yaml_data->{'custom_configs'}->{$custom},
                    $total_lists,
                    $tt,
                    $subscriber_cache,
                    $custom);
    print "Created $created lists for $custom\n";
    $total_lists += $created;
  }
  for (my $i = $total_lists+1; $i <= $yaml_data->{'total_lists'}; $i++) {
    my %defaults_copy = %defaults;
    foreach my $k ('owners', 'moderators') {
      $defaults_copy{$k} = [@{$defaults{$k}}] if (ref($defaults{$k}) eq "ARRAY");
    }
    create_list(\%defaults_copy, $i, $tt, $subscriber_cache);
  }
}

sub create_lists {
  my %config = %{$_[0]};
  my %custom_config = %{$_[1]};
  my $total_lists = $_[2] +1;
  my $tt = $_[3];
  my $subscriber_cache = $_[4];
  my $custom_name = $_[5];
  my $count = 0;

  foreach my $k (keys %custom_config) {
    $config{$k} = $custom_config{$k};
  }
  
  for (my $i=0; $i < $config{'count'}; $i++) {
    my $this_listname;
    my %config_copy = %config;
    foreach my $k ('owners', 'moderators') {
      $config_copy{$k} = [@{$config{$k}}] if (ref($config{$k}) eq "ARRAY");
    }
    if (create_list(\%config_copy, $total_lists + $i, $tt, $subscriber_cache, $custom_name)) {
      $count++;
    }
  }
  unless ($count == $config{'count'}) {
    print "WARNING! Only created $count lists but should have created $config{'count'}\n";
  }
  return $count;
}

sub create_list {
  my $i = $_[1];
  my %config = interpolate_values_in_hash($_[0], $i);
  my $tt = $_[2]; 
  my $subscriber_cache = $_[3];
  my $custom_name = $_[4] || 'default';
  my $num_subscribers = get_subscriber_count(\%config);
  my $exit_code;

  open(XML, ">".TMP_XML) || die "Cannot open tmp xml file for writing: $!\n";
  $tt->process(LIST_DEF, \%config, TMP_XML) || die($tt->error());
  close XML; 

  $exit_code = system(SYMPA_PATH, "--create_list", "--input_file", TMP_XML, "--robot", "foo.com");

  if ($exit_code == 0) {
    print "created list $config{'listname'} for $custom_name. moderators are: ".((ref($config{'moderators'}) eq "ARRAY") ? join (", ", @{$config{'moderators'}}) : "empty")."\n";
    if ($num_subscribers > 0) {
print "adding $num_subscribers subscribers.\n";
      add_subscribers($config{'listname'}, $subscriber_cache, $num_subscribers);
    }
    return 1;
  }else {
    print STDERR "Error creating list $config{'listname'}. Please check the sympa logs\n";
    return 0;
  }
}

sub get_subscriber_count {
  my %config = %{$_[0]};
  my @possible_counts;

  return 0 if $config{'subscribers_max'} == 0;

  # we want a random number in the range between
  # $config{'subscribers_min'} and $config{'subscribers_max'}
  # since rand() can only count from 0, generate an array of the 
  # numbers of subscribers, then use rand to pick a random index
 
  @possible_counts = ($config{'subscribers_min'} .. $config{'subscribers_max'});
  return $possible_counts[int(rand(scalar(@possible_counts)-1))];
}

sub add_subscribers {
  my $listname = shift;
  my $subscriber_cache = shift;
  my $count = shift;
  my @subscribers = $subscriber_cache->($count);
  my $subscriber_string = join("\n", @subscribers);  
  my $cmd = "echo \"$subscriber_string\" | ".SYMPA_PATH." --import=$listname\@foo.com";
  print `$cmd`;
  # just out of curiosity
  if ($count <= 10) {
    print "Subscribers added: ".join(', ', @subscribers)."\n";
  }
}

# create a closure to store the subscribers created
sub subscriber_cache {
  my @subscribers;
  return sub {
    my $needed = shift || 0;
    my $last_possible_splice_start;
    my $splice_start;

    return if $needed == 0;

    while (scalar(@subscribers) < $needed) {
      push @subscribers, 'subscriber_'.(scalar(@subscribers)+1).'@foo.com';
    }

    # we want to attempt to not always splice from 0 so that subscriber_0 isn't 
    # subscribed to every list
    if (scalar(@subscribers) > $needed) {
      # pick some starting value that is greater than 0 and 
      # less than the last starting point that would be possible
      $last_possible_splice_start = scalar(@subscribers) - $needed - 1;
      $splice_start = int(rand($last_possible_splice_start));
      # would use splice() here except that modifies the @subscribers array directly
      return @subscribers[$splice_start..($splice_start+($needed-1))]
    }else {
      # would use splice() here except that modifies the @subscribers array directly
       return @subscribers[0..($needed-1)]
    }
  }
}

sub interpolate_values_in_hash {
  my $config = $_[0];
  my $i = $_[1];
  foreach my $k (keys %{$config}) {
    if (ref($config->{$k}) eq "ARRAY") {
      for (my $x=0; $x < scalar(@{$config->{$k}}); $x++) {
        $config->{$k}->[$x] =~ s/\[% i %\]/$i/g;
      }
    } 
    $config->{$k} =~ s/\[% i %\]/$i/g;
  }
  return %{$config};
}

sub check_files {
  my $notfound = 0;
  foreach my $f (LIST_DEF, LISTS_YAML, LIST_DATA) {
    unless (-e $f) {
      print STDERR "Required file $f not found.";
      $notfound++ && next;  
    } 
    unless (-r $f) {
      print STDERR "Required file $f found but not readable.";
      $notfound++;
    }
  }
  return $notfound;
}

sub help {
  print <<EOF;

USAGE:  ./create_lists.pl --setup|teardown|help [--list_data=/path/to/list_data]

required, one of:
  --setup	create lists as defined in lists.yml
  --teardown	remove all lists (leaves users)
  --refresh	runs teardown followed by setup
  --help	print usage

optional:
  --list_data	path to list data directory, defaults to /home/sympa/list_data (sympa's default)

EOF
}
