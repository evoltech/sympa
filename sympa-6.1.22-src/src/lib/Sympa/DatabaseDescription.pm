# Sympa::Constants.pm - This module contains all installation-related variables
# RCS Identication ; $Revision: 5768 $ ; $Date: 2009-05-21 16:23:23 +0200 (jeu. 21 mai 2009) $ 
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

package Sympa::DatabaseDescription;
use strict;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(db_struct %not_null %primary %indexes %former_indexes %autoincrement);

sub db_struct {

    my %db_struct = ('mysql' => {
				'user_table' => {'email_user' => 'varchar(100)',
						  'gecos_user' => 'varchar(150)',
						  'password_user' => 'varchar(40)',
						  'last_login_date_user' => 'int(11)',
						  'last_login_host_user' => 'varchar(60)',
						  'wrong_login_count_user' => 'int(11)',
						  'cookie_delay_user' => 'int(11)',
						  'lang_user' => 'varchar(10)',
						  'attributes_user' => 'text',
						  'data_user' => 'text'},
				 'subscriber_table' => {'list_subscriber' => 'varchar(50)',
							'user_subscriber' => 'varchar(100)',
							'robot_subscriber' => 'varchar(80)',
							'date_subscriber' => 'datetime',
							'update_subscriber' => 'datetime',
							'visibility_subscriber' => 'varchar(20)',
							'reception_subscriber' => 'varchar(20)',
							'topics_subscriber' => 'varchar(200)',
							'bounce_subscriber' => 'varchar(35)',
							'comment_subscriber' => 'varchar(150)',
							'subscribed_subscriber' => "int(1)",
							'included_subscriber' => "int(1)",
							'include_sources_subscriber' => 'varchar(50)',
							'bounce_score_subscriber' => 'smallint(6)',
							'bounce_address_subscriber' => 'varchar(100)',
							'custom_attribute_subscriber' => 'text',
							'suspend_subscriber' => "int(1)",
							'suspend_start_date_subscriber' => 'int(11)',
							'suspend_end_date_subscriber' => 'int(11)'},
				 'admin_table' => {'list_admin' => 'varchar(50)',
						   'user_admin' => 'varchar(100)',
						   'robot_admin' => 'varchar(80)',
						   'role_admin' => "enum('listmaster','owner','editor')",
						   'date_admin' => 'datetime',
						   'update_admin' => 'datetime',
						   'reception_admin' => 'varchar(20)',
						   'visibility_admin' => 'varchar(20)',
						   'comment_admin' => 'varchar(150)',
						   'subscribed_admin' => "int(1)",
						   'included_admin' => "int(1)",
						   'include_sources_admin' => 'varchar(50)',
						   'info_admin' =>  'varchar(150)',
						   'profile_admin' => "enum('privileged','normal')"},
				 'exclusion_table' => {'list_exclusion' => 'varchar(50)',
						       'robot_exclusion' => 'varchar(50)',
						       'family_exclusion' => 'varchar(50)',
						       'user_exclusion' => 'varchar(100)',
						       'date_exclusion' => 'int(11)'},
				 'netidmap_table' => {'netid_netidmap' => 'varchar(100)',
						      'serviceid_netidmap' => 'varchar(100)',
						      'email_netidmap' => 'varchar(100)',
						      'robot_netidmap' => 'varchar(80)'},
				 'session_table' => {'id_session' => 'varchar(30)',
						     'start_date_session' => 'int(11)',
						     'prev_id_session' => 'varchar(30)',
						     'refresh_date_session' => 'int(11)',
						     'date_session' => 'int(11)',
						     'remote_addr_session' => 'varchar(60)',
						     'robot_session'  => 'varchar(80)',
						     'email_session'  => 'varchar(100)',
						     'hit_session' => 'int(11)',
						     'data_session'  => 'text'},
				 'logs_table' => {'id_logs' => 'bigint(20)',
						  'date_logs' => 'int(11)',
						  'robot_logs' => 'varchar(80)',
						  'list_logs' => 'varchar(50)',
						  'action_logs' => 'varchar(50)',
						  'parameters_logs' => 'varchar(100)',
						  'target_email_logs' => 'varchar(100)',
						  'user_email_logs' => 'varchar(100)',
						  'msg_id_logs' => 'varchar(255)',
						  'status_logs' => 'varchar(10)',
						  'error_type_logs' => 'varchar(150)',
						  'client_logs' => 'varchar(100)',
						  'daemon_logs' => 'varchar(10)'},
				 'one_time_ticket_table' => {'ticket_one_time_ticket' => 'varchar(30)',
							     'email_one_time_ticket' => 'varchar(100)',
							     'robot_one_time_ticket' => 'varchar(80)',
							     'date_one_time_ticket' => 'int(11)',
							     'data_one_time_ticket' => 'varchar(200)',
							     'remote_addr_one_time_ticket' => 'varchar(60)',
							     'status_one_time_ticket' => 'varchar(60)'},
				##FIXME: column name is "recEipients_bulkmailer"
				 'bulkmailer_table' => {'messagekey_bulkmailer' => 'varchar(80)',
							'messageid_bulkmailer' => 'varchar(200)',
							'packetid_bulkmailer' => 'varchar(33)',
							'receipients_bulkmailer' => 'text',
							'returnpath_bulkmailer' => 'varchar(100)',
							'robot_bulkmailer' => 'varchar(80)',
							'listname_bulkmailer' => 'varchar(50)',
							'verp_bulkmailer' => 'int(1)',
							'merge_bulkmailer' => 'int(1)',
							'priority_message_bulkmailer' => 'smallint(10)',
							'priority_packet_bulkmailer' => 'smallint(10)',
							'reception_date_bulkmailer' => 'int(11)',
							'delivery_date_bulkmailer' => 'int(11)',
							'lock_bulkmailer' => 'varchar(30)'},
				 'bulkspool_table' => {'messagekey_bulkspool' => 'varchar(33)',
						       'messageid_bulkspool' => 'varchar(200)',
						       'message_bulkspool' => 'longtext',
						       'lock_bulkspool' => 'int(1)',
						       'dkim_privatekey_bulkspool' => 'varchar(2000)',
						       'dkim_selector_bulkspool' => 'varchar(50)',
						       'dkim_d_bulkspool' => 'varchar(50)',
						       'dkim_i_bulkspool' => 'varchar(100)',
						   },
				 'conf_table' => {'robot_conf' => 'varchar(80)',
						  'label_conf' => 'varchar(80)',
						  'value_conf' => 'varchar(300)'},
                  'list_table' => {'name_list'=>'varchar(100)',
                                    'path_list'=>'varchar(100)',
                                    'robot_list'=>'varchar(100)',
                                    'status_list'=>"enum('open','closed','pending','error_config','family_closed')",
                                    'creation_email_list'=>'varchar(100)',
                                    'creation_epoch_list'=>'datetime',
                                    'subject_list'=>'varchar(100)',
                                    'web_archive_list'=>'tinyint(1)',
                                    'topics_list'=>'varchar(100)',
                                    'editors_list'=>'varchar(100)',
                                    'owners_list'=>'varchar(100)'}
                              },
		   );
  
  foreach my $table ( keys %{ $db_struct{'mysql'} } ) {		
      foreach my $field  ( keys %{ $db_struct{'mysql'}{$table}  }) {
	  my $trans = $db_struct{'mysql'}{$table}{$field};
	  my $trans_o = $trans;
	  my $trans_pg = $trans;
	  my $trans_syb = $trans;
	  my $trans_sq = $trans;
# Oracle	
	  $trans_o =~ s/^varchar/varchar2/g;	
	  $trans_o =~ s/^int.*/number/g;	
	  $trans_o =~ s/^bigint.*/number/g;	
	  $trans_o =~ s/^smallint.*/number/g;	
	  $trans_o =~ s/^enum.*/varchar2(20)/g;	
	  $trans_o =~ s/^text.*/varchar2(500)/g;	
	  $trans_o =~ s/^longtext.*/long/g;	
	  $trans_o =~ s/^datetime.*/date/g;	
#Postgresql
	  $trans_pg =~ s/^int(1)/smallint/g;
	  $trans_pg =~ s/^int\(?.*\)?/int4/g;
	  $trans_pg =~ s/^smallint.*/int4/g;
	  $trans_pg =~ s/^tinyint\(.*\)/int2/g;
	  $trans_pg =~ s/^bigint.*/int8/g;
	  $trans_pg =~ s/^text.*/varchar(500)/g;
	  $trans_pg =~ s/^longtext.*/text/g;
	  $trans_pg =~ s/^datetime.*/timestamptz/g;
	  $trans_pg =~ s/^enum.*/varchar(15)/g;
#Sybase		
	  $trans_syb =~ s/^int.*/numeric/g;
	  $trans_syb =~ s/^text.*/varchar(500)/g;
	  $trans_syb =~ s/^smallint.*/numeric/g;
	  $trans_syb =~ s/^bigint.*/numeric/g;
	  $trans_syb =~ s/^longtext.*/text/g;
	  $trans_syb =~ s/^enum.*/varchar(15)/g;
#Sqlite		
	  $trans_sq =~ s/^varchar.*/text/g;
	  $trans_sq =~ s/^longtext/text/g;
	  $trans_sq =~ s/^int\(1\).*/numeric/g;
	  $trans_sq =~ s/^int.*/integer/g;
	  $trans_sq =~ s/^tinyint.*/integer/g;
	  $trans_sq =~ s/^bigint.*/integer/g;
	  $trans_sq =~ s/^smallint.*/integer/g;
	  $trans_sq =~ s/^datetime.*/numeric/g;
	  $trans_sq =~ s/^enum.*/text/g;	 
	  
	  $db_struct{'Pg'}{$table}{$field} = $trans_pg;
	  $db_struct{'Oracle'}{$table}{$field} = $trans_o;
	  $db_struct{'Sybase'}{$table}{$field} = $trans_syb;
	  $db_struct{'SQLite'}{$table}{$field} = $trans_sq;
      }
  }   
  return %db_struct;
}


our %not_null = ('email_user' => 1,
		'list_subscriber' => 1,
		'robot_subscriber' => 1,
		'user_subscriber' => 1,
		'date_subscriber' => 1,
		'list_admin' => 1,
		'robot_admin' => 1,
		'user_admin' => 1,
		'role_admin' => 1,
		'date_admin' => 1,
		'list_exclusion' => 1,
		'user_exclusion' => 1,
		'robot_exclusion' => 1,
		'netid_netidmap' => 1,
		'serviceid_netidmap' => 1,
		'robot_netidmap' => 1,
		'id_logs' => 1,
		'date_logs' => 1,
		'action_logs' => 1,
		'status_logs' => 1,
		'daemon_logs' => 1,
		'id_session' => 1,
		'start_date_session' => 1,
		'date_session' => 1,
		'messagekey_bulkmailer' => 1,
		'packetid_bulkmailer' => 1,
		'messagekey_bulkspool' => 1,
		'name_list' => 1,
		'robot_list' => 1,
	);

our %primary = ('user_table' => ['email_user'],
	       'subscriber_table' => ['robot_subscriber','list_subscriber','user_subscriber'],
	       'admin_table' => ['robot_admin','list_admin','role_admin','user_admin'],
	       'exclusion_table' => ['list_exclusion','user_exclusion','robot_exclusion'],
	       'netidmap_table' => ['netid_netidmap','serviceid_netidmap','robot_netidmap'],
	       'logs_table' => ['id_logs'],
	       'session_table' => ['id_session'],
	       'one_time_ticket_table' => ['ticket_one_time_ticket'],
	       'bulkmailer_table' => ['messagekey_bulkmailer','packetid_bulkmailer'],
	       'bulkspool_table' => ['messagekey_bulkspool'],
	       'conf_table' => ['robot_conf','label_conf'],
		   'list_table' => ['name_list','robot_list'],
	       );
	       
our %autoincrement = (
);

## List the required INDEXES
##   1st key is the concerned table
##   2nd key is the index name
##   the table lists the field on which the index applies
our %indexes = ('admin_table' => {'admin_user_index' => ['user_admin']},
	       'subscriber_table' => {'subscriber_user_index' => ['user_subscriber']},
	       );

# table indexes that can be removed during upgrade process
our @former_indexes = ('user_subscriber', 'list_subscriber', 'subscriber_idx', 'admin_idx', 'netidmap_idx', 'user_admin', 'list_admin', 'role_admin', 'admin_table_index', 'logs_table_index','netidmap_table_index','subscriber_table_index','user_index');

return 1;
