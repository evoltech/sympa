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

   $self->{_dbh} = DBI->connect
   (
      "dbi:mysql:". $self->{database}, 
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


1;
