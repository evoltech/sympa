# SQLSource.pm - This module includes SQL DB related functions
#<!-- RCS Identication ; $Revision: 10083 $ --> 

#
# Sympa - SYsteme de Multi-Postage Automatique
#
# Copyright (c) 1997, 1998, 1999 Institut Pasteur & Christophe Wolfhugel
# Copyright (c) 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
# 2006, 2007, 2008, 2009, 2010, 2011 Comite Reseau des Universites
# Copyright (c) 2011, 2012, 2013, 2014 GIP RENATER
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package SQLSource;

use strict;

use Carp;
use DBI;
use Exporter;

use Conf;
use Log;
use List;
use tools;
use tt2;

our @ISA = qw(Exporter);
our @EXPORT = qw(%date_format);
our @EXPORT_OK = qw(connect query disconnect fetch create_db ping quote set_fetch_timeout);

our %date_format = (
		   'read' => {
		       'Pg' => 'date_part(\'epoch\',%s)',
		       'mysql' => 'UNIX_TIMESTAMP(%s)',
		       'Oracle' => '((to_number(to_char(%s,\'J\')) - to_number(to_char(to_date(\'01/01/1970\',\'dd/mm/yyyy\'), \'J\'))) * 86400) +to_number(to_char(%s,\'SSSSS\'))',
		       'Sybase' => 'datediff(second, \'01/01/1970\',%s)',
		       'SQLite' => 'strftime(\'%%s\',%s,\'utc\')'
		       },
		   'write' => {
		       'Pg' => '\'epoch\'::timestamp with time zone + \'%d sec\'',
		       'mysql' => 'FROM_UNIXTIME(%d)',
		       'Oracle' => 'to_date(to_char(floor(%s/86400) + to_number(to_char(to_date(\'01/01/1970\',\'dd/mm/yyyy\'), \'J\'))) || \':\' ||to_char(mod(%s,86400)), \'J:SSSSS\')',
		       'Sybase' => 'dateadd(second,%s,\'01/01/1970\')',
		       'SQLite' => 'datetime(%d,\'unixepoch\',\'localtime\')'
		       }
	       );

## Structure to keep track of active connections/connection status
## Key : connect_string (includes server+port+dbname+DB type)
## Values : dbh,status,first_try
## "status" can have value 'failed'
## 'first_try' contains an epoch date
my %db_connections;

############################################################
#  connect
############################################################
#  Connect to an SQL database. This could be called as
#  a SQLSource object member, or as a static sub. 
#  
# IN : -$param_ref : ref to a Hash of config data if statically
#       called
#      -$options : ref to a hash. Options for the connection process.
#         currently accepts 'keep_trying' : wait and retry until
#         db connection is ok (boolean) ; 'warn' : warn
#         listmaster if connection fails (boolean)
# OUT : $dbh
#     | undef
#
##############################################################
sub connect {
    my $self = undef;
    my ($param, $options) = @_;
    # are we called as an instance member ?
    if (ref($param) ne 'HASH') {
    	$self = $param;
    	$param = $self->{'param'};
    }
    
    $param->{'db_host'} ||= $param->{'host'};
    $param->{'db_user'} ||= $param->{'user'};
    $param->{'db_passwd'} ||= $param->{'passwd'};
    $param->{'db_options'} ||= $param->{'connect_options'};
    
    ## Do we have db_xxx required parameters
    foreach my $db_param ('db_type','db_name') {
	unless ($param->{$db_param}) {
	    do_log('info','Missing parameter %s for DBI connection', $db_param);
	    return undef;
	}
    }
    if ($param->{'db_type'} eq 'SQLite') {
        ## SQLite just need a db_name
    } elsif ($param->{'db_type'} eq 'ODBC') {
        ## ODBC just needs a db_name, db_user
	foreach my $db_param ('db_user','db_passwd') {
	    unless ($param->{$db_param}) {
		do_log('info','Missing parameter %s for DBI connection', $db_param);
		return undef;
	    }
	}
    } else {
	foreach my $db_param ('db_host','db_user','db_passwd') {
	    unless ($param->{$db_param}) {
		do_log('info','Missing parameter %s for DBI connection', $db_param);
		return undef;
	    }
	}
    }

    my $connect_string;
    ## Check if DBD is installed
    unless (eval "require DBD::$param->{'db_type'}") {
	do_log('err',"No Database Driver installed for $param->{'db_type'} ; you should download and install DBD::$param->{'db_type'} from CPAN");
	&List::send_notify_to_listmaster('missing_dbd', $Conf::Conf{'domain'},{'db_type' => $param->{'db_type'}});
	return undef;
    }

    ## Build connect_string
    if ($param->{'f_dir'}) {
	$connect_string = "DBI:CSV:f_dir=$param->{'f_dir'}";
    }elsif ($param->{'db_type'} eq 'Oracle') {
	$connect_string = "DBI:Oracle:";
	if ($param->{'db_host'} && $param->{'db_name'}) {
	    $connect_string .= "host=$param->{'db_host'};sid=$param->{'db_name'}";
	}
    }elsif ($param->{'db_type'} eq 'Pg') {
	$connect_string = "DBI:Pg:dbname=$param->{'db_name'};host=$param->{'db_host'}";
    }elsif ($param->{'db_type'} eq 'Sybase') {
	$connect_string = "DBI:Sybase:database=$param->{'db_name'};server=$param->{'db_host'}";
    }elsif ($param->{'db_type'} eq 'SQLite') {
	$connect_string = "DBI:SQLite:dbname=$param->{'db_name'}";
    }elsif ($param->{'db_type'} eq 'Informix') {
        $connect_string = "DBI:Informix:".$param->{'db_name'}."@".$param->{'db_host'}; 
    # ODBC support
    }elsif ($param->{'db_type'} eq 'ODBC') {
	$connect_string = "DBI:ODBC:".$param->{'db_name'};
    }else {
	$connect_string = "DBI:$param->{'db_type'}:$param->{'db_name'}:$param->{'db_host'}";
    }

    if ($param->{'db_options'}) {
	$connect_string .= ';' . $param->{'db_options'};
    }
    if (defined $param->{'db_port'}) {
	$connect_string .= ';port=' . $param->{'db_port'};
    }
 
    ## First check if we have an active connection with this server
    ## We require that user also matches (except SQLite).
    if (defined $db_connections{$connect_string} && 
	($param->{'db_type'} eq 'SQLite' or
	 $db_connections{$connect_string}{'db_user'} eq $param->{'db_user'}) &&
	defined $db_connections{$connect_string}{'dbh'} && 
	$db_connections{$connect_string}{'dbh'}->ping()) {
      
      &do_log('debug', "Use previous connection");
      $self->{'dbh'} = $db_connections{$connect_string}{'dbh'} if $self;
      return $db_connections{$connect_string}{'dbh'};

    }else {
      
      ## Set environment variables
      ## Used by Oracle (ORACLE_HOME)

      ## Client encoding derived from the environment variable.
      ## Set this before parsing db_env to allow override if one knows what
      ## she is doing.
      ## Note: on mysql and Pg, "SET NAMES" will be executed below; on SQLite,
      ## no need to set encoding.
      if ($param->{'db_type'} eq 'Oracle') {
	## NLS_LANG.  This needs to be set before connecting, otherwise it's
	## useless.  Underscore (_) and dot (.) are a vital part as NLS_LANG
	## has the syntax "language_territory.charset".
	$ENV{'NLS_LANG'} = '_.UTF8';
      } elsif ($param->{'db_type'} eq 'Sybase') {
	$ENV{'SYBASE_CHARSET'} = 'utf8';
      }

      if ($param->{'db_env'}) {
	foreach my $env (split /;/,$param->{'db_env'}) {
	  my ($key, $value) = split /=/, $env;
	  $ENV{$key} = $value if ($key);
	}
      }
      
    my $dbh;
    {
	local $@; # # protect existing $@
	eval {$dbh = DBI->connect($connect_string, $param->{'db_user'}, $param->{'db_passwd'}, { PrintError => 0 })};
	unless ($dbh) {
	    ## Notify listmaster if warn option was set
	    ## Unless the 'failed' status was set earlier
	    if ($options->{'warn'}) {
		unless (defined $db_connections{$connect_string} &&
		    $db_connections{$connect_string}{'status'} eq 'failed') { 
    
		    unless (&List::send_notify_to_listmaster('no_db', $Conf::Conf{'domain'},{})) {
			&do_log('err',"Unable to send notify 'no_db' to listmaster");
		    }
		}
	    }
	    if ($options->{'keep_trying'}) {
		&do_log('err','Can\'t connect to Database %s as %s, still trying...', $connect_string, $param->{'db_user'});
	    } else{
		do_log('err','Can\'t connect to Database %s as %s', $connect_string, $param->{'db_user'});
		$db_connections{$connect_string}{'status'} = 'failed';
		$db_connections{$connect_string}{'first_try'} ||= time;
		return undef;
	    }
	    ## Loop until connect works
	    my $sleep_delay = 60;
	    while (1) {
		sleep $sleep_delay;
		eval {$dbh = DBI->connect($connect_string, $param->{'db_user'}, $param->{'db_passwd'}, { PrintError => 0 })};
		last if ($dbh && $dbh->ping());
		$sleep_delay += 10;
	    }
	    
	    if ($options->{'warn'}) {
	    do_log('notice','Connection to Database %s restored.', $connect_string);
		unless (&List::send_notify_to_listmaster('db_restored', $Conf::Conf{'domain'},{})) {
		    &do_log('notice',"Unable to send notify 'db_restored' to listmaster");
		}
	    }
	}
	
      }

      # mysql:
      # - At first, reset "mysql_auto_reconnect" driver attribute.
      #   connect() sets it to true not according to \%attr argument
      #   when the processes are running under mod_perl or CGI environment so
      #   that "SET NAMES utf8" will be skipped.
      # - Set client-side character set to "utf8" or "utf8mb4".
      if ($param->{'db_type'} eq 'mysql') {
	    $dbh->{'mysql_auto_reconnect'} = 0;

	    unless (defined $dbh->do("SET NAMES 'utf8mb4'") or
		defined $dbh->do("SET NAMES 'utf8'")) {
		do_log('err', 'Cannot set client-side character set: %s',
		    $dbh->errstr);
	    }
      }

      # Pg:
      # - Configure Postgres to use ISO format dates.
      # - Set client encoding to UTF8.
      if ($param->{'db_type'} eq 'Pg') {
	$dbh->do ("SET DATESTYLE TO 'ISO';");
	$dbh->do("SET NAMES 'utf8'");
      }
      
      ## added sybase support
      if ($param->{'db_type'} eq 'Sybase') { 
	my $dbname;
	$dbname="use $param->{'db_name'}";
        $dbh->do ($dbname);
      }
      
      ## Force field names to be lowercased
      ## This has has been added after some problems of field names upercased with Oracle
      $dbh->{'FetchHashKeyName'}='NAME_lc';

      if ($param->{'db_type'} eq 'SQLite') { # Configure to use sympa database
        $dbh->func( 'func_index', -1, sub { return index($_[0],$_[1]) }, 'create_function' );
	if(defined $param->{'db_timeout'}) { $dbh->func( $param->{'db_timeout'}, 'busy_timeout' ); } else { $dbh->func( 5000, 'busy_timeout' ); };
      }
      
      $self->{'dbh'} = $dbh if $self;
      $self->{'connect_string'} = $connect_string if $self;     
      $db_connections{$connect_string}{'dbh'} = $dbh;
      $db_connections{$connect_string}{'db_user'} = $param->{'db_user'};
      
      do_log('debug2','Connected to Database %s',$param->{'db_name'});
      return $dbh;
    }
}

sub query {
    my ($self, $sql_query) = @_;
    unless ($self->{'sth'} = $self->{'dbh'}->prepare($sql_query)) {
        do_log('err','Unable to prepare SQL query : %s', $self->{'dbh'}->errstr);
        return undef;
    }
    unless ($self->{'sth'}->execute) {
        do_log('err','Unable to perform SQL query %s : %s ',$sql_query, $self->{'dbh'}->errstr);
        return undef;
    }

}

sub fetch {
    my $self = shift;
	
    ## call to fetchrow_arrayref() uses eval to set a timeout
    ## this prevents one data source to make the process wait forever if SELECT does not respond
    my $array_of_users;
    $array_of_users = eval {
	local $SIG{ALRM} = sub { die "TIMEOUT\n" }; # NB: \n required
	alarm $self->{'fetch_timeout'}; 
	
	## Inner eval just in case the fetchall_arrayref call would die, thus leaving the alarm trigered
	my $status = eval {
	    return $self->{'sth'}->fetchall_arrayref;
	};
	alarm 0;
	return $status;
    };
    if ( $@ eq "TIMEOUT\n" ) {
	do_log('err','Fetch timeout on remote SQL database');
        return undef;
    }elsif ($@) {
	do_log('err','Fetch failed on remote SQL database');
    return undef;
    }

    return $array_of_users;
}

sub disconnect {
    my $self = shift;
    $self->{'sth'}->finish if $self->{'sth'};
    $self->{'dbh'}->disconnect;
    delete $db_connections{$self->{'connect_string'}};
}

## Try to create the database
sub create_db {
    &do_log('debug3', 'List::create_db()');    

    &do_log('notice','Trying to create %s database...', $Conf::Conf{'db_name'});

    unless ($Conf::Conf{'db_type'} eq 'mysql') {
	&do_log('err', 'Cannot create %s DB', $Conf::Conf{'db_type'});
	return undef;
    }

    my $drh;
    unless ($drh = DBI->connect("DBI:mysql:dbname=mysql;host=localhost", 'root', '')) {
	&do_log('err', 'Cannot connect as root to database');
	return undef;
    }

    ## Create DB
    my $rc = $drh->func("createdb", $Conf::Conf{'db_name'}, 'localhost', $Conf::Conf{'db_user'}, $Conf::Conf{'db_passwd'}, 'admin');
    unless (defined $rc) {
	&do_log('err', 'Cannot create database %s : %s', $Conf::Conf{'db_name'}, $drh->errstr);
	return undef;
    }

    ## Re-connect to DB (to prevent "MySQL server has gone away" error)
    unless ($drh = DBI->connect("DBI:mysql:dbname=mysql;host=localhost", 'root', '')) {
	&do_log('err', 'Cannot connect as root to database');
	return undef;
    }

    ## Grant privileges
    unless ($drh->do("GRANT ALL ON $Conf::Conf{'db_name'}.* TO '$Conf::Conf{'db_user'}'\@localhost IDENTIFIED BY '$Conf::Conf{'db_passwd'}'")) {
	&do_log('err', 'Cannot grant privileges to %s on database %s : %s', $Conf::Conf{'db_user'}, $Conf::Conf{'db_name'}, $drh->errstr);
	return undef;
    }

    &do_log('notice', 'Database %s created', $Conf::Conf{'db_name'});

    ## Reload MysqlD to take changes into account
    $rc = $drh->func("reload", $Conf::Conf{'db_name'}, 'localhost', $Conf::Conf{'db_user'}, $Conf::Conf{'db_passwd'}, 'admin');
    unless (defined $rc) {
	&do_log('err', 'Cannot reload mysqld : %s', $drh->errstr);
	return undef;
    }

    $drh->disconnect();

    return 1;
}

sub ping {
    my $self = shift;
    return $self->{'dbh'}->ping; 
}

sub quote {
    my ($self, $string, $datatype) = @_;
    
    return $self->{'dbh'}->quote($string, $datatype); 
}

sub set_fetch_timeout {
    my ($self, $timeout) = @_;

    return $self->{'fetch_timeout'} = $timeout;
}

## Packages must return true.
1;
