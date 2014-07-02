package SympaDB;

use strict;
use warnings;

use DBI;
use DBD::mysql;
use Data::Dumper;

#these values should be read from a config file

sub new {
   my ($class, $options) = @_;
   my $self = {};
   my $object = bless($self, $class);
   $object->{server} = $options->{server} ? $options->{server} : 'localhost';
   $object->{username} = $options->{username} ? $options->{username} : "root";
   $object->{password} = $options->{password} ? $options->{password} : '';
   $object->{database} = $options->{database} ? 
    $options->{database} : 'localhost';
   $object->{debug} = $options->{debug} ? $options->{debug} : 0;
   return $object;
}

sub init {
   my ($self) = @_;
   return 1 if (defined($self->{init}) && $self->{init} == 1);
	 my $dsn = 'dbi:mysql:host='. $self->{server} .';dbname='. $self->{database};

   $self->{_dbh} = DBI->connect
   (
			$dsn,
      $self->{username},
      $self->{password},
      {
         PrintError => 1,
         RaiseError => 1
      }
   ) || 
   die ("unable to establish connection\n");

   $self->{selectRandomUser} = 
     'SELECT * from user_table ORDER BY RAND() LIMIT 1';
   $self->{selectRandomUserSTH}= 
    $self->{_dbh}->prepare ($self->{selectRandomUser});

   $self->{selectMaxUserId} = 
     'SELECT max(id) as id from user_table';
   $self->{selectMaxUserIdSTH}= 
    $self->{_dbh}->prepare ($self->{selectMaxUserId});

   $self->{selectUserById} = 
     'SELECT * from user_table where id=?';
   $self->{selectUserByIdSTH}= 
    $self->{_dbh}->prepare ($self->{selectUserById});

   $self->{insertSubscriber} = 
     'INSERT into subscriber_table ('.
       'list_subscriber, user_subscriber, custom_attribute_subscriber, '.
       'robot_subscriber, date_subscriber, update_subscriber, '.
       'visibility_subscriber, reception_subscriber, comment_subscriber, '.
       'subscribed_subscriber, included_subscriber)'.
     'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
   $self->{insertSubscriberSTH}= 
    $self->{_dbh}->prepare ($self->{insertSubscriber});

   $self->{selectUserEmailByList} = 
     'SELECT user_subscriber from subscriber_table '.
        'where list_subscriber=? and robot_subscriber=?';
   $self->{selectUserEmailByListSTH}= 
    $self->{_dbh}->prepare ($self->{selectUserEmailByList});

   $self->{selectUserEmailByDomain} = 
     'SELECT user_subscriber from subscriber_table '.
        'where user_subscriber like ?';
   $self->{selectUserEmailByDomainSTH}= 
    $self->{_dbh}->prepare ($self->{selectUserEmailByDomain});

   $self->{updateUserEmailInSubscriberTable} = 
     'UPDATE subscriber_table set user_subscriber = ? '.
        'where user_subscriber = ?';
   $self->{updateUserEmailInSubscriberTableSTH}= 
    $self->{_dbh}->prepare ($self->{updateUserEmailInSubscriberTable});

   $self->{selectUsers} = 
			'SELECT gecos_user,email_user,password_user FROM user_table';
   $self->{selectUsersSTH}= 
    $self->{_dbh}->prepare ($self->{selectUsers});

   $self->{clearUsersName} = 
			'UPDATE user_table set gecos_user=NULL where email_user=?';
   $self->{clearUsersNameSTH}= 
    $self->{_dbh}->prepare ($self->{clearUsersName});

}

sub getUserEmailsByList {
  my ($self, $list_name, $domain_name) = @_;
  init($self);

  eval {
    $self->{selectUserEmailByListSTH}->execute($list_name, $domain_name); 
  };
  if ($@) {
     warn 'Could not get a user email list for the list '.
        $list_name .'@'. $domain_name ."$!\n";
     return -1;
  }
 
  my $emails;
  while (my $subscriber = 
    $self->{selectUserEmailByListSTH}->fetchrow_hashref('NAME_lc')) {
    push (@$emails, $subscriber->{user_subscriber});
  }

  return $emails;

  # This should really be an iterator tied to a variable.
  my $user = $self->{selectUserEmailByListSTH}->fetchrow_hashref('NAME_lc') ;

}

sub subscribe_user {
  my ($self, $list, $user, $cas, $rs, $ds, $vs, $res, $cs, $ss, $is) = @_;
  init($self);

  eval {$self->{insertSubscriberSTH}->execute(
    $list, $user, $cas, $rs, $ds, $ds, $vs, $res, $cs, $ss, $is); 
  };
  if ($@) {
     warn "Could not insert a subscriber row for ".
      "list=$list, user=$user.\n";
     return -1;
  }
}

sub get_random_user {
  my ($self) = @_;
  init($self);

  eval {$self->{selectMaxUserIdSTH}->execute(); };
  if ($@) {
     warn "Could not get a max user id.$!\n";
     return -1;
  }
  my $user = $self->{selectMaxUserIdSTH}->fetchrow_hashref('NAME_lc') ;
  my $max_user_id = $user->{id};
  srand();
  my $random_user_id = int(rand($max_user_id));

  eval {$self->{selectUserByIdSTH}->execute($random_user_id); };
  if ($@) {
     warn "Could not get a user with id = $random_user_id.\n";
     return -1;
  }
  return $self->{selectUserByIdSTH}->fetchrow_hashref('NAME_lc') ;
}

sub rewriteUserEmailDomains {
  my ($self, $target, $destination) = @_;
  init($self);

  eval {$self->{selectUserEmailByDomainSTH}->execute('%'. $target); };
  if ($@) {
     warn "Could not get users with domain: $target.$@\n";
     return -1;
  }
  while (my $subscriber = 
    $self->{selectUserEmailByDomainSTH}->fetchrow_hashref('NAME_lc')) {
    my $old_email = $subscriber->{user_subscriber};
    my $new_email = $old_email;
    $new_email =~ s/$target/$destination/;
    $self->{updateUserEmailInSubscriberTableSTH}->execute(
      $new_email, $old_email);
  }
}

sub getUsers {
  my ($self) = @_;
	my $users;
  init($self);

  eval {
    $self->{selectUsersSTH}->execute(); 
  };
  if ($@) {
     warn "Could not get a user list from the DB: $!\n";
     return -1;
  }

  while (my $user = 
    $self->{selectUsersSTH}->fetchrow_hashref('NAME_lc')) {
    push (@$users, {'email' =>  $user->{email_user}, 'name' => $user->{gecos_user}});
  }

	return $users;
}

sub clearUserName {
  my ($self, $email) = @_;
	
  eval {
		$self->{clearUsersNameSTH}->execute($email)
  };
  if ($@) {
     warn 'Could not clear name for user with email '. $email .": $!\n";
     return -1;
  }

	return 1;
}

1;
