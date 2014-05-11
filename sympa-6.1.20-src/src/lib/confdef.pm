# Conf.pm - This module does the sympa.conf and robot.conf parsing
# RCS Identication ; $Revision: 5688 $ ; $Date: 2009-04-30 14:49:42 +0200 (jeu, 30 avr 2009) $ 
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

package confdef;

use strict "vars";

use Sympa::Constants;

## This defines the parameters to be edited :
##   title  : Title for the group of parameters following
##   name   : Name of the parameter
##   file   : Conf file where the parameter is defined.  If omitted, the
##            parameter won't be added automatically to the config file, even
##            if a default is set.
##   default: Default value : DON'T SET AN EMPTY DEFAULT VALUE ! It's useless
##            and can lead to errors on fresh install.
##   query  : Description of the parameter
##   advice : Additionnal advice concerning the parameter
##   sample : FIXME FIXME
##   edit   : 1|0: FIXME FIXME
##   optional: 1|0: FIXME FIXME
##   vhost  : 1|0 : if 1, the parameter can have a specific value in a
##            virtual host
##   db     : 'db_first', 'file_first', 'no'
##   obfuscated: 1|0: FIXME FIXME

our @params = (
    { 'title' => 'Site customization' },

    {
        'name'    => 'domain',
        'default' => 'domain.tld',
        'query'   => 'Main robot hostname',
        'edit'    => '1',
        'file'    => 'sympa.conf',
        #vhost   => '1', #FIXME:not yet implemented
    },
    {
        'name'    => 'host',
        'optional' => 1,
	'vhost'   => '1',
    },
    {
        'name'    => 'email',
        'default' => 'sympa',
        'query'   => 'Local part of sympa email address',
	'vhost'   => '1',
        'edit'    => '1',
        'file'    => 'sympa.conf',
        'advice'  => 'Effective address will be [EMAIL]@[HOST]',
    },
    ##{ email_gecos: not yet implemented. },
    {
        'name'    => 'listmaster',
        'default' => 'your_email_address@domain.tld',
        'query'   => 'Listmasters email list comma separated',
        'file'    => 'sympa.conf',
        'vhost'   => '1',
        'edit'    => '1',
        'advice'  => 'Sympa will associate listmaster privileges to these email addresses (mail and web interfaces). Some error reports may also be sent to these addresses.',
    },
    {
        'name'    => 'listmaster_email',
        'default' => 'listmaster',
        'query'   => 'Local part of listmaster email address',
	'vhost'   => '1',
    },
    {
        'name'    => 'wwsympa_url',
        'default' => 'http://host.domain.tld/sympa',
        'query'   => 'URL of main Web page',
	'vhost'   => '1',
        'file'    => 'sympa.conf',
        'edit'    => '1',
    },
    {
        'name'    => 'soap_url',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name'    => 'max_wrong_password',
        'default' => '19',
        'vhost' => '1',
	'file'   => 'sympa.conf',
    },
    {
        'name'    => 'spam_protection',
        'default' => 'javascript',
	'vhost'   => '1',
    },
    {
        'name'    => 'web_archive_spam_protection',
        'default' => 'cookie',
	'vhost'   => '1',
    },
    {
        'name'    => 'color_0',
        'default' => '#ffcd9d', # very light grey use in tables
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_1',
        'default' => '#999', # main menu button color
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_2',
        'default' => '#333',  # font color
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_3',
        'default' => '#ccccff', # top boxe and footer box bacground color
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_4',
        'default' => '#f77d18', #  page backgound color
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_5',
        'default' => '#fff',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name' => 'color_6',
        'default' => '#99ccff', # list menu current button
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_7',
        'default' => '#ff99cc', # errorbackground color
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_8',
        'default' => '#3366CC',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name' => 'color_9',
        'default' => '#DEE7F7',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
     {
        'name'    => 'color_10',
        'default' => '#777777', # inactive button
	'vhost'   => '1',
	'db'      => 'db_first',
    },
     {
        'name'    => 'color_11',
        'default' => '#ccc',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_12',
        'default' => '#000',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_13',
        'default' => '#ffffce',  # input backgound  | transparent
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_14',
        'default' => '#f4f4f4',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'color_15',
        'default' => '#000',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name' => 'dark_color',
        'default' => 'silver',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'light_color',
        'default' => '#aaddff',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'text_color',
        'default' => '#000000',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'bg_color',
        'default' => '#ffffcc',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'error_color',
        'default' => '#ff6666',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'selected_color',
        'default' => 'silver',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name'    => 'shaded_color',
        'default' => '#66cccc',
	'vhost'   => '1',
	'db'      => 'db_first',
    },
    {
        'name' => 'logo_html_definition',
        'optional' => '1',
	'vhost'   => '1',
    },
    ##{ favicon_url: not yet implemented. },
    {
        'name' => 'main_menu_custom_button_1_title',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name' => 'main_menu_custom_button_1_url',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name' => 'main_menu_custom_button_1_target',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name' => 'main_menu_custom_button_2_title',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name' => 'main_menu_custom_button_2_url',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name' => 'main_menu_custom_button_2_target',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name' => 'main_menu_custom_button_3_title',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name' => 'main_menu_custom_button_3_url',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name' => 'main_menu_custom_button_3_target',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name'    => 'css_path',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name'    => 'css_url',
        'optional' => '1',
	'vhost'   => '1',
    },
    {
        'name'    => 'static_content_path',
        'default' => Sympa::Constants::STATICDIR,
        'query'   => 'Directory for storing static contents (CSS, members pictures, documentation) directly delivered by Apache',
	'vhost'   => '1',
        'edit'    => '1',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'static_content_url',
        'default' => '/static-sympa',
        'query'   => 'URL mapped with the static_content_path directory defined above',
	'vhost'   => '1',
        'edit'    => '1',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'pictures_feature',
        'default' => 'on',
    },
    {
        'name'    => 'pictures_max_size',
        'default' => 102400, ## 100 kiB
	'vhost'   => '1',
    },
    {
        'name'    => 'cookie',
        'sample'  => '123456789',
        'query'   => 'Secret used by Sympa to make MD5 fingerprint in web cookies secure',
        'file'   => 'sympa.conf',
        'advice' => 'Should not be changed ! May invalid all user password',
        'optional' => '1',
    },
    {
        'name'    => 'create_list',
        'default' => 'public_listmaster',
        'query'   => 'Who is able to create lists',
	'vhost'   => '1',
        'file'    => 'sympa.conf',
        'edit'    => '1',
        'advice'  => 'This parameter is a scenario, check sympa documentation about scenarios if you want to define one',
    },
    {
        'name'    => 'global_remind',
        'default' => 'listmaster',
    },
    {
        'name'    => 'allow_subscribe_if_pending',
        'default' => 'on',
	'vhost'   => '1',
    },
    {
        'name'    => 'custom_robot_parameter',
        'query'   => 'Used to define a custom parameter for your server. Do not forget the semicolon between the param name and the param value.',
	'vhost'   => '1',
        'file'    => 'sympa.conf',
	'optional' => '1',
    },

    { 'title' => 'Directories' },

    {
        'name'    => 'home',
        'default' => Sympa::Constants::EXPLDIR,
        'query'   => 'Directory containing mailing lists subdirectories',
        'file'    => 'sympa.conf',
        'edit'    => '1',
    },
    {
        'name'    => 'etc',
        'default' => Sympa::Constants::SYSCONFDIR,
        'query'   => 'Directory for configuration files; it also contains scenari/ and templates/ directories',
        'file'    => 'sympa.conf',
    },

    { 'title' => 'System related' },

    {
        'name'    => 'syslog',
        'default' => 'LOCAL1',
        'query'   => 'Syslog facility for sympa',
        'file'    => 'sympa.conf',
        'edit'    => '1',
        'advice'  => 'Do not forget to edit syslog.conf',
    },
    {
        'name'    => 'log_level',
        'default' => '0',
        'query'   => 'Log verbosity',
	'vhost'   => '1',
        'file'    => 'sympa.conf',
        'advice'  => '0: normal, 2,3,4: for debug',
    },
    {
        'name'    => 'log_socket_type',
        'default' => 'unix',
        'query'   => 'Communication mode with syslogd (unix | inet)',
        'file'    => 'sympa.conf',
    },
##    {
##        'name'    => 'pidfile',
##        'default' => Sympa::Constants::PIDDIR . '/sympa.pid',
##        'query'   => 'File containing Sympa PID while running.',
##        'file'    => 'sympa.conf',
##        'advice'  => 'Sympa also locks this file to ensure that it is not running more than once. Caution : user sympa need to write access without special privilegee.',
##    },
##    {
##        'name'    => 'pidfile_distribute',
##        'default' => Sympa::Constants::PIDDIR . '/sympa-distribute.pid',
##        'file'    => 'sympa.conf',
##    },
##    {
##        'name'    => 'pidfile_creation',
##        'default' => Sympa::Constants::PIDDIR . '/sympa-creation.pid',
##        'file'    => 'sympa.conf',
##    },
##    {
##        'name'  => 'task_manager_pidfile',
##        'default' => Sympa::Constants::PIDDIR . '/task_manager.pid',
##        'query' => 'File containing task_manager PID while running.',
##        'file'  => 'wwsympa.conf',
##    },
    {
        'name'    => 'log_condition',
        'optional' => '1',
	'vhost'   => '1',
	'file'    => 'wwsympa.conf',
    },
    {
        'name'    => 'log_module',
        'optional' => '1',
	'vhost'   => '1',
	'file'    => 'wwsympa.conf',
    },
    {
        'name'    => 'umask',
        'default' => '027',
        'query'   => 'Umask used for file creation by Sympa',
        'file'    => 'sympa.conf',
    },

    { 'title' => 'Sending related' },

    {
        'name'    => 'sendmail',
        'default' => '/usr/sbin/sendmail',
        'query'   => 'Path to the MTA (sendmail, postfix, exim or qmail)',
        'file'    => 'sympa.conf',
        'edit'    => '1',
        'advice'  => 'should point to a sendmail-compatible binary (eg: a binary named "sendmail" is distributed with Postfix)',
    },
    {
        'name' => 'sendmail_args',
        'default' => '-oi -odi -oem',
    },
    {
        'name'    => 'distribution_mode',
        'default' => 'single',
    },
    {
        'name'    => 'maxsmtp',
        'default' => '40',
        'query'   => 'Max. number of Sendmail processes (launched by Sympa) running simultaneously',
        'file'    => 'sympa.conf',
        'advice'  => 'Proposed value is quite low, you can rise it up to 100, 200 or even 300 with powerfull systems.',
    },
    {
        'name'    => 'merge_feature',
	'default' => 'off',
    },
    {
        'name'    => 'automatic_list_removal',
        'default' => 'none', ## Can be 'if_empty'
        'vhost'   => '1',
    },
    {
        'name'    => 'automatic_list_feature',
        'default' => 'off',
        'vhost'   => '1',
    },
    {
        'name'    => 'automatic_list_creation',
        'default' => 'public',
        'vhost'   => '1',
    },
    {
        'name'    => 'automatic_list_families',
        'query'   => 'Defines the name of the family the automatic lists are based on.',
        'file'    => 'sympa.conf',
        'optional' => '1',
        'vhost'   => '1',
    },
    {
        'name'    => 'automatic_list_prefix',
        'query'   => 'Defines the prefix allowing to recognize that a list is an automatic list.',
        'file'    => 'sympa.conf',
        'optional' => '1',
    },
    {
        'name'    => 'log_smtp',
        'default' => 'off',
	'vhost'   => '1',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'use_blacklist',
        'query'   => 'comma separated list of operations for which blacklist filter is applied',
        'default' => 'send,create_list',
	'vhost'   => '1',
        'file'    => 'sympa.conf',
        'edit'    => '1',
        'advice'  => 'Setting this parameter to "none" will hide the blacklist feature',
    },
    ##{ reporting_spam_script_path: not yet implemented. },
    {
        'name'  => 'max_size',
        'query' => 'Default maximum size (in bytes) for messages (can be re-defined for each list)',
        'default' => '5242880', ## 5 MiB
	'vhost'   => '1',
        'file'  => 'sympa.conf',
        'edit'  => '1',
    },
    {
        'name'    => 'misaddressed_commands',
        'default' => 'reject',
    },
    {
        'name'    => 'misaddressed_commands_regexp',
        'default' => '(subscribe|unsubscribe|signoff|set\s+(\S+)\s+(mail|nomail|digest))',
    },
    {
        'name'    => 'nrcpt',
        'default' => '25',
        'query'   => 'Maximum number of recipients per call to Sendmail. The nrcpt_by_domain.conf file allows a different tuning per destination domain.',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'avg',
        'default' => '10',
        'query'   => 'Max. number of different domains per call to Sendmail',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'alias_manager',
        'default' => Sympa::Constants::SBINDIR . '/alias_manager.pl',
    },
    {
        'name'    => 'db_list_cache',
        'default' => 'off',
        'advice'  => 'Whether or not to cache lists in the database',
    },
    {
        'name' => 'sendmail_aliases',
        'default' => Sympa::Constants::SENDMAIL_ALIASES,
        'query'   => 'Path of the file that contains all list related aliases',
        'vhost'   => '1',
    },
    {
        'name' => 'aliases_program',
        'default' => 'newaliases',
        'query' => 'Program used to update alias database.  "makemap", "newaliases", "postalias", "postmap" or full path to custom program',
        'vhost'   => '1',
    },
    {
        'name' => 'aliases_db_type',
        'default' => 'hash',
        'query' => 'Type of alias database.  "btree", "dbm", "hash" and so on.  Available when aliases_program is "makemap", "postalias" or "postmap"',
        'vhost'   => '1',
    },
    {
        'name'    => 'rfc2369_header_fields',
        'query'   => 'Specify which rfc2369 mailing list headers to add',
        'default' => 'help,subscribe,unsubscribe,post,owner,archive',
        'file'    => 'sympa.conf',
    },
    {
        'name'   => 'remove_headers',
        'query'  => 'Specify header fields to be removed before message distribution',
        'default' => 'X-Sympa-To,X-Family-To,Return-Receipt-To,Precedence,X-Sequence,Disposition-Notification-To',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'remove_outgoing_headers',
        'default' => 'none',
    },
    {
        'name'   => 'reject_mail_from_automates_feature',
        'query'  => 'Reject mail from automates (crontab, etc) sent to a list?',
        'default' => 'on',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'ignore_x_no_archive_header_feature',
        'default' => 'off',
    },
    {
        'name'    => 'anonymous_header_fields',
        'default' => 'Authentication-Results,DKIM-Signature,Disposition-Notification-To,Injection-Info,Organisation,Organization,Original-Recipient,Originator,Path,Received,Received-SPF,Reply-To,Resent-Reply-To,Return-Receipt-To,X-Envelope-From,X-Envelope-To,X-Sender,X-X-Sender',
    },
    {
        'name'    => 'list_check_smtp',
        'optional' => '1',
        'query'    => 'SMTP server to which Sympa verify if alias with the same name as the list to be created',
        'vhost'   => '1',
        'advice'   => 'Default value is real FQDN of host. Set [HOST]:[PORT] to specify non-standard port.',
    },
    {
        'name'    => 'list_check_suffixes',
        'default' => 'request,owner,editor,unsubscribe,subscribe',
	'vhost'   => '1',
    },
    {
        'name'     => 'list_check_helo',
        'optional' => '1',
        'query'    => 'SMTP HELO (EHLO) parameter used for alias verification',
        'vhost'    => '1',
        'advice'   => 'Default value is the host part of list_check_smtp parameter.',
    },
    {
        'name'    => 'urlize_min_size',
        'default' => 10240, ## 10 kiB
    },
    {
	'name'    => 'sender_headers',
	'default' => 'From',
	'sample'  => 'Resent-From,From,Return-Path',
	'query'   => 'Header field name(s) used to determine sender of the messages',
	'advice'  => '"Return-Path" means envelope sender (a.k.a. "UNIX From") which will be alternative to sender of messages without "From" field.  "Resent-From" may also be inserted before "From", because some mailers add it into redirected messages and keep original "From" field intact.  In particular cases, "Return-Path" can not give right sender: several mail gateway products rewrite envelope sender and add original one as non-standard field such as "X-Envelope-From".  If that is the case, you might want to insert it in place of "Return-Path".',
    },

    { 'title' => 'Bulk mailer' },

##    {
##        'name'    => 'pidfile_bulk',
##        'default' => Sympa::Constants::PIDDIR . '/bulk.pid',
##        'file'    => 'sympa.conf',
##    },
    {
        'name'  => 'sympa_packet_priority',
        'query' => 'Default priority for a packet to be sent by bulk.',
        'file'  => 'sympa.conf',
        'default' => '5',
        vhost => '1',
    },
    {
        'name'    => 'bulk_fork_threshold',
        'default' => '1',
        'query'   => 'Minimum number of packets in database before the bulk forks to increase sending rate',
        'file'    => 'sympa.conf',
        'advice'  => '',
    },
    {
        'name'    => 'bulk_max_count',
        'default' => '3',
        'query'   => 'Max number of bulks that will run on the same server',
        'file'    => 'sympa.conf',
        'advice'  => '',
    },
    {
        'name'    => 'bulk_lazytime',
        'default' => '600',
        'query'   => 'The number of seconds a slave bulk will remain running without processing a message before it spontaneously dies.',
        'file'    => 'sympa.conf',
        'advice'  => '',
    },
    {
        'name'    => 'bulk_sleep',
        'default' => '1',
        'query'   => "The number of seconds a bulk sleeps between starting a new loop if it didn't find a message to send.",
        'file'    => 'sympa.conf',
        'advice'  => 'Keep it small if you want your server to be reactive.',
    },
    {
        'name'    => 'bulk_wait_to_fork',
        'default' => '10',
        'query'   => 'Number of seconds a master bulk waits between two packets number checks.',
        'file'    => 'sympa.conf',
        'advice'  => 'Keep it small if you expect brutal increases in the message sending load.',
    },

    { 'title' => 'Quotas' },

    ##{ default_max_list_members: not yet implemented. },
    {
        'name'  => 'default_shared_quota',
        'optional' => '1',
        'query' => 'Default disk quota for shared repository',
	'vhost'   => '1',
        'file'  => 'sympa.conf',
        'edit'  => '1',
    },
    {
        'name'    => 'default_archive_quota',
        'optional' => '1',
    },

    { 'title' => 'Spool related' },

    {
        'name'    => 'spool',
        'default' => Sympa::Constants::SPOOLDIR,
        'query'   => 'Directory containing various specialized spools',
        'file'    => 'sympa.conf',
        'advice' => 'All spool are created at runtime by sympa.pl',
    },
    {
        'name'    => 'queue',
        'default' => Sympa::Constants::SPOOLDIR . '/msg',
        'query'   => 'Directory for incoming spool',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'queuedistribute',
        'default'  => Sympa::Constants::SPOOLDIR . '/distribute',
	'file'    => 'sympa.conf',
    },
    {
        'name'    => 'queuemod',
        'default' => Sympa::Constants::SPOOLDIR . '/moderation',
        'query'   => 'Directory for moderation spool',
	'file'    => 'sympa.conf',
    },
    {
        'name'    => 'queuedigest',
        'default' => Sympa::Constants::SPOOLDIR . '/digest',
        'query'   => 'Directory for digest spool',
	'file'    => 'sympa.conf',
    },
    {
        'name'    => 'queueauth',
        'default' => Sympa::Constants::SPOOLDIR . '/auth',
        'query'   => 'Directory for authentication spool',
	'file'    => 'sympa.conf',
    },
    {
        'name'    => 'queueoutgoing',
        'default' => Sympa::Constants::SPOOLDIR . '/outgoing',
        'query'   => 'Directory for outgoing spool',
	'file'    => 'sympa.conf',
    },
    {
        'name'    => 'queuesubscribe',
        'default' => Sympa::Constants::SPOOLDIR . '/subscribe',
        'query'   => 'Directory for subscription spool',
	'file'    => 'sympa.conf',
    },
    {
        'name'    => 'queuetopic',
        'default' => Sympa::Constants::SPOOLDIR . '/topic',
        'query'   => 'Directory for topic spool',
	'file'    => 'sympa.conf',
    },
    ##{ queuesignoff: not yet implemented. },
    {
        'name'    => 'queuebounce',
        'default' => Sympa::Constants::SPOOLDIR . '/bounce',
        'query'   => 'Directory for bounce incoming spool',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'queuetask',
        'default' => Sympa::Constants::SPOOLDIR . '/task',
        'query'   => 'Directory for task spool',
	'file'    => 'sympa.conf',
    },
    {
        'name'    => 'queueautomatic',
        'default' => Sympa::Constants::SPOOLDIR . '/automatic',
        'query'   => 'Directory for automatic list creation spool',
	'file'    => 'sympa.conf',
    },
    {
        'name'    => 'sleep',
        'default' => '5',
        'advice'   => 'Must not be 0.',
    },
    {
        'name'     => 'tmpdir',
        'default'  => Sympa::Constants::SPOOLDIR . '/tmp',
        'query'    => 'Temporary directory used by OpenSSL, antivirus plugins, mhonarc etc',
    },
    ##{ viewmail_dir: not yet implemented. },
    {
        'name'    => 'clean_delay_queue',
        'default' => '7',
    },
    {
        'name'    => 'clean_delay_queueoutgoing',
        'default' => '7',
    },
    {
        'name'    => 'clean_delay_queuebounce',
        'default' => '7',
    },
    {
        'name'    => 'clean_delay_queuemod',
        'default' => '30',
    },
    {
        'name'    => 'clean_delay_queueauth',
        'default' => '30',
    },
    {
        'name'    => 'clean_delay_queuesubscribe',
        'default' => '30',
    },
    ##{ clean_delay_queuesignoff: not yet implemented. },
    {
        'name'    => 'clean_delay_queuetopic',
        'default' => '30',
    },
    {
        'name'    => 'clean_delay_queueautomatic',
        'default' => '10',
    },
    {
        'name'    => 'clean_delay_tmpdir',
        'default' => '7',
    },

    { 'title' => 'Internationalization related' },

##    {
##        name    => 'localedir',
##        default => Sympa::Constants::LOCALEDIR,
##        query   => 'Directory containing available NLS catalogues (Message internationalization)',
##        file    => 'sympa.conf',
##    },
    {
        'name'    => 'supported_lang',
        'default' => 'ca,cs,de,el,es,et_EE,en,fr,fi,hu,it,ja_JP,ko,nl,nb_NO,oc,pl,pt_BR,ru,sv,tr,vi,zh_CN,zh_TW',
        'query'   => 'Supported languages',
	'vhost'   => '1',
        'file'    => 'sympa.conf',
        'edit'    => '1',
        'advice'  => "This is the set of language that will be proposed to your users for the Sympa GUI. Don't select a language if you don't have the proper locale packages installed.",
    },
    {
        'name'    => 'lang',
        'default' => 'en',
        'query'   => 'Default language (one of supported languages)',
	'vhost'   => '1',
        'file'    => 'sympa.conf',
        'edit'    => '1',
        'advice'  => 'This is the default language used by Sympa',
    },
    {
        'name'   => 'legacy_character_support_feature',
        'default' => 'off',
        'query'  => 'If set to "on", enables support of legacy character set',
        'file'   => 'sympa.conf',
        'advice' => 'In some language environments, legacy encoding (character set) is preferred for e-mail messages: for example iso-2022-jp in Japanese language.',
    },
    {
        'name'    => 'filesystem_encoding',
        'default' => 'utf-8',
    },

    { 'title' => 'Bounce related' },

    {
        'name'    => 'verp_rate',
        'default' => '0%',
	'vhost'   => '1',
    },
    {
        'name'   => 'welcome_return_path',
        'default' => 'owner',
        'query'  => 'Welcome message return-path ( unique | owner )',
        'file'   => 'sympa.conf',
        'advice' => 'If set to unique, new subcriber is removed if welcome message bounce',
    },
    {
        'name'   => 'remind_return_path',
        'default' => 'owner',
        'query'  => 'Remind message return-path ( unique | owner )',
        'file'   => 'sympa.conf',
        'advice' => 'If set to unique, subcriber is removed if remind message bounce, use with care',
    },
    {
        'name'    => 'return_path_suffix',
        'default' => '-owner',
    },
    {
        'name'    => 'bounce_path',
        'default' => Sympa::Constants::BOUNCEDIR ,
        'query'   => 'Directory for storing bounces',
        'file'    => 'wwsympa.conf',
        'advice'  => 'Better if not in a critical partition',
    },
##    {
##        'name'   => 'bounced_pidfile',
##        'default' => Sympa::Constants::PIDDIR . '/bounced.pid',
##        'query'  => 'File containing bounced PID while running.',
##        'file'   => 'wwsympa.conf',
##    },
    {
        'name'   => 'expire_bounce_task',
        'default' => 'daily',
        'query'  => 'Task name for expiration of old bounces',
        'file'   => 'sympa.conf',
    },
    {
        'name'    => 'purge_orphan_bounces_task',
        'default' => 'monthly',
    },
    {
        'name'    => 'eval_bouncers_task',
        'default' => 'daily',
    },
    {
        'name'    => 'process_bouncers_task',
        'default' => 'weekly',
    },
    {
        'name'    => 'minimum_bouncing_count',
        'default' => '10',
    },
    {
        'name'    => 'minimum_bouncing_period',
        'default' => '10',
    },
    {
        'name'    => 'bounce_delay',
        'default' => '0',
    },
    {
        'name'    => 'default_bounce_level1_rate',
        'default' => '45',
	'vhost'   => '1',
    },
    {
        'name'    => 'default_bounce_level2_rate',
        'default' => '75',
	'vhost'   => '1',
    },
    {
        'name'    => 'bounce_email_prefix',
        'default' => 'bounce',
    },
    {
        'name'   => 'bounce_warn_rate',
        'default' => '30',
        'query'  => 'Bouncing email rate for warn list owner',
        'file'   => 'sympa.conf',
        'edit'   => '1',
    },
    {
        'name'   => 'bounce_halt_rate',
        'default' => '50',
        'query'  => 'Bouncing email rate for halt the list (not implemented)',
        'file'   => 'sympa.conf',
        'advice' => 'Not yet used in current version, Default is 50',
    },
    ##{ tracking_default_retention_period: not yet implemented. },
    ##{ tracking_delivery_status_notification: not yet implemented. },
    ##{ tracking_message_delivery_notification: not yet implemented. },
    {
        'name'    => 'default_remind_task',
        'optional' => '1',
    },

    { 'title' => 'Tuning' },

    {
        'name'    => 'cache_list_config',
        'default' => 'none',
        'query'   => 'Use of binary version of the list config structure on disk (none | binary_file)',
        'file'    => 'sympa.conf',
        'edit'    => '1',
        'advice'  => 'Set this parameter to "binary_file" if you manage a big amount of lists (1000+); it should make the web interface startup faster',
    },
    {
        'name'    => 'lock_method',
        'default' => 'flock',
        'advice'  => 'flock | nfs',
    },
    {
        'name'  => 'sympa_priority',
        'query' => 'Sympa commands priority',
        'file'  => 'sympa.conf',
        'default' => '1',
        'vhost' => '1',
    },
    {
        'name'    => 'request_priority',
        'default' => '0',
	'file'  => 'sympa.conf',
        'vhost' => '1',
    },
    {
        'name'    => 'owner_priority',
        'default' => '9',
	'file'  => 'sympa.conf',
        'vhost' => '1',
    },
    {
        'name'  => 'default_list_priority',
        'query' => 'Default priority for list messages',
        'file'  => 'sympa.conf',
        'default' => '5',
        'vhost' => '1',
    },

    {
        'name'  => 'parsed_family_files',
        'query' => 'comma-separated list of files that will be parsed by Sympa when instantiating a family (no space allowed in file names)',
        'file'  => 'sympa.conf',
        'default' => 'message.footer,message.header,message.footer.mime,message.header.mime,info',
        'vhost' => '1',
    },

    { 'title' => 'Database related' },

    {
        'name'    => 'update_db_field_types',
        'default' => 'auto',
    },
    {
        'name'    => 'db_type',
        'default' => 'mysql',
        'query'   => 'Type of the database (mysql|ODBC|Oracle|Pg|SQLite|Sybase)',
        'file'    => 'sympa.conf',
        'edit'    => '1',
        'advice'  => 'Be careful to the case',
    },
    {
        'name'    => 'db_name',
        'default' => 'sympa',
        'query'   => 'Name of the database',
        'file'    => 'sympa.conf',
        'edit'    => '1',
        'advice'  => 'With SQLite, the name of the DB corresponds to the DB file',
    },
    {
        'name'   => 'db_host',
        'default' => 'localhost',
        'sample' => 'localhost',
        'query'  => 'Hostname of the database server',
        'file'   => 'sympa.conf',
        'edit'   => '1',
    },
    {
        'name'   => 'db_port',
        'default' => undef,
        'query'  => 'Port of the database server',
        'file'   => 'sympa.conf',
        'optional' => '1',
    },
    {
        'name'   => 'db_user',
        'default' => 'user_name',
        'sample' => 'sympa',
        'query'  => 'User for the database connection',
        'file'   => 'sympa.conf',
        'edit'   => '1',
    },
    {
        'name'   => 'db_passwd',
        'default' => 'user_password',
        'sample' => 'your_passwd',
        'query'  => 'Password for the database connection',
        'file'   => 'sympa.conf',
        'edit'   => '1',
        'obfuscated' => '1',
        'advice' => 'What ever you use a password or not, you must protect the SQL server (is it not a public internet service ?)',
    },
    {
        'name'    => 'db_timeout',
        'optional' => '1',
    },
    {
        'name'    => 'db_options',
        'optional' => '1',
    },
    {
        'name'   => 'db_env',
        'query'  => 'Environment variables setting for database',
        'file'   => 'sympa.conf',
        'advice' => 'This is useful for defining ORACLE_HOME ',
        'optional' => '1',
    },
    {
        'name'   => 'db_additional_subscriber_fields',
        'sample' => 'billing_delay,subscription_expiration',
        'query'  => 'Database private extention to subscriber table',
        'file'   => 'sympa.conf',
        'advice' => 'You need to extend the database format with these fields',
        'optional' => '1',
    },
    {
        'name'   => 'db_additional_user_fields',
        'sample' => 'age,address',
        'query'  => 'Database private extention to user table',
        'file'   => 'sympa.conf',
        'advice' => 'You need to extend the database format with these fields',
        'optional' => '1',
    },
    {
        'name'    => 'purge_user_table_task',
        'default' => 'monthly',
    },
    {
        'name' => 'purge_tables_task',
        'default' => 'daily',
    },
    {
        'name' => 'purge_logs_table_task',
        'default' => 'daily',
    },
    {
        'name'    => 'logs_expiration_period',
        'query'   => 'Number of months that elapse before a log is expired',
        'default' => '3',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'purge_one_time_ticket_table_task',
        'default' => 'daily',
    },
    {
        'name'    => 'one_time_ticket_table_ttl',
        'default' => '10d',
    },
    {
        'name'    => 'purge_session_table_task',
        'default' => 'daily',
    },
    {
        'name'    => 'session_table_ttl',
        'default' => '2d',
    },
    {
        'name'    => 'anonymous_session_table_ttl',
        'default' => '1h',
    },
    {
        'name'    => 'purge_challenge_table_task',
        'default' => 'daily',
    },
    {
        'name' => 'challenge_table_ttl',
        'default' => '5d',
    },
    {
        'name'  => 'default_ttl',
        'query' => 'Default timeout between two scheduled synchronizations of list members with data sources.',
        'file'  => 'sympa.conf',
        'default' => '3600',
    },
    {
        'name'  => 'default_distribution_ttl',
        'query' => 'Default timeout between two action-triggered synchronizations of list members with data sources.',
        'file'  => 'sympa.conf',
        'default' => '300',
    },
   {
        'name'  => 'default_sql_fetch_timeout',
        'query' => 'Default timeout while performing a fetch for an include_sql_query sync',
        'file'  => 'sympa.conf',
        'default' => '300',
    },

    { 'title' => 'Loop prevention' },

    {
        'name'    => 'loop_command_max',
        'default' => '200',
    },
    {
        'name'    => 'loop_command_sampling_delay',
        'default' => '3600',
    },
    {
        'name'    => 'loop_command_decrease_factor',
        'default' => '0.5',
    },
    {
        'name'    => 'loop_prevention_regex',
        'default' => 'mailer-daemon|sympa|listserv|majordomo|smartlist|mailman',
	'vhost'   => '1',
    },
    ##{ msgid_table_cleanup_ttl: not yet implemented. },
    ##{ msgid_table_cleanup_frequency: not yet implemented. },

    { 'title' => 'S/MIME configuration' },

    {
        'name'   => 'openssl',
        'sample' => '/usr/bin/ssl',
        'query'  => 'Path to OpenSSL',
        'file'   => 'sympa.conf',
        'edit'   => '1',
        'advice' => 'Sympa recognizes S/MIME if OpenSSL is installed',
	'optional' => '1',
    },
    {
        'name'   => 'capath',
        'optional' => '1',
        'sample' => Sympa::Constants::SYSCONFDIR . '/ssl.crt',
        'query'  => 'Directory containing trusted CA certificates',
        'file'   => 'sympa.conf',
        'edit'   => '1',
        'optional' => '1',
    },
    {
        'name'   => 'cafile',
        'sample' => '/usr/local/apache/conf/ssl.crt/ca-bundle.crt',
        'query'  => 'File containing bundled trusted CA certificates',
        'file'   => 'sympa.conf',
        'edit'   => '1',
        'optional' => '1',
    },
    {
        'name'    => 'crl_dir',
        'default' => Sympa::Constants::EXPLDIR . '/crl',
        'file'    => 'sympa.conf',
    },
    {
        'name'    => 'ssl_cert_dir',
        'default' => Sympa::Constants::EXPLDIR . '/X509-user-certs',
        'query'   => 'Directory containing user certificates',
        'file'    => 'sympa.conf',
    },
    {
        'name'   => 'key_passwd',
        'sample' => 'your_password',
        'query'  => 'Password used to crypt lists private keys',
        'file'   => 'sympa.conf',
        'edit'   => '1',
        'optional'   => '1',
    },

    { 'title' => 'DKIM' },

    {
        'name'    => 'dkim_feature',
        'default' => 'off',
        'vhost' => '1',
	'file'   => 'sympa.conf',
    },
    {
        'name'    => 'dkim_add_signature_to',
        'default' => 'robot,list',
	'advice'  => 'Insert a DKIM signature to message from the robot, from the list or both',
        'vhost' => '1',
	'file'   => 'sympa.conf',
    },
    {
        'name'    => 'dkim_signature_apply_on',
        'default' => 'md5_authenticated_messages,smime_authenticated_messages,dkim_authenticated_messages,editor_validated_messages',
	'advice'  => 'Type of message that is added a DKIM signature before distribution to subscribers. Possible values are "none", "any" or a list of the following keywords: "md5_authenticated_messages", "smime_authenticated_messages", "dkim_authenticated_messages", "editor_validated_messages".',
        'vhost' => '1',
	'file'   => 'sympa.conf',
    },
    {
        'name' => 'dkim_private_key_path',
	'vhost' => '1',
        'query'   => 'Location of the file where DKIM private key is stored',
	'optional' => '1',
	'file'   => 'sympa.conf',
    },
    {
        'name' => 'dkim_signer_domain',
	'vhost' => '1',
        'query'   => 'The "d=" tag as defined in rfc 4871, default is virtual host domain name',
	'optional' => '1',
	'file'   => 'sympa.conf',
    },
    {
        'name' => 'dkim_selector',
	'vhost' => '1',
        'query'   => 'The selector',
	'optional' => '1',
	'file'   => 'sympa.conf',
    },
    {
        'name' => 'dkim_signer_identity',
	'vhost' => '1',
        'query'   => 'The "i=" tag as defined in rfc 4871, default is null',
	'optional' => '1',
	'file'   => 'sympa.conf',
    },
    ##{
	##name => 'dkim_header_list',
        ##vhost => '1',
	##file   => 'sympa.conf',
        ##query   => 'list of headers to be included ito the message for signature',
        ##default => 'from:sender:reply-to:subject:date:message-id:to:cc:list-id:list-help:list-unsubscribe:list-subscribe:list-post:list-owner:list-archive:in-reply-to:references:resent-date:resent-from:resent-sender:resent-to:resent-cc:resent-message-id:mime-version:content-type:content-transfer-encoding:content-id:content-description',
    ##},

    { 'title' => 'Antivirus plug-in' },

    {
        'name'   => 'antivirus_path',
        'optional' => '1',
        'sample' => '/usr/local/uvscan/uvscan',
        'query'  => 'Path to the antivirus scanner engine',
        'file'   => 'sympa.conf',
        'edit'   => '1',
        'advice' => 'Supported antivirus: McAfee/uvscan, Fsecure/fsav, Sophos, AVP and Trend Micro/VirusWall',
    },
    {
        'name'   => 'antivirus_args',
        'optional' => '1',
        'sample' => '--secure --summary --dat /usr/local/uvscan',
        'query'  => 'Antivirus plugin command argument',
        'file'   => 'sympa.conf',
        'edit'   => '1',
    },
    {
        'name'    => 'antivirus_notify',
        'default' => 'sender',
    },

    { 'title' => 'Tag based spam filtering' },

    {
        'name'    => 'antispam_feature',
        'default' => 'off',
	'vhost'   => '1',
    },
    {
        'name'  => 'antispam_tag_header_name',
        'default' => 'X-Spam-Status',
        'query' => 'If a spam filter (like spamassassin or j-chkmail) add a smtp headers to tag spams, name of this header (example X-Spam-Status)',
	'vhost'   => '1',
        'file'  => 'sympa.conf',
        'edit'  => '1',
    },
    {
        'name'   => 'antispam_tag_header_spam_regexp',
        'default' => '^\s*Yes',
        'query'  => 'Regexp applied on this header to verify message is a spam (example \s*Yes)',
	'vhost'   => '1',
        'file'   => 'sympa.conf',
        'edit'   => '1',
    },
    {
        'name'  => 'antispam_tag_header_ham_regexp',
        'default' => '^\s*No',
        'query' => 'Regexp applied on this header to verify message is NOT a spam (example \s*No)',
	'vhost'   => '1',
        'file'  => 'sympa.conf',
        'edit'  => '1',
    },
    {
        'name'  => 'spam_status',
        'default' => 'x-spam-status',
        'query' => 'Messages are supposed to be filtered by an antispam that add one more headers to messages. This parameter is used to select a special scenario in order to decide the message spam status: ham, spam or unsure. This parameter replace antispam_tag_header_name, antispam_tag_header_spam_regexp and antispam_tag_header_ham_regexp.',
	'vhost'   => '1',
        'file'  => 'sympa.conf',
        'edit'  => '1',
    },

    { 'title' => 'Web interface parameters' },

    {
        'name'    => 'arc_path',
        'default' => Sympa::Constants::ARCDIR,
        'query'   => 'Directory for storing HTML archives',
        'file'    => 'wwsympa.conf',
	'edit' => '1',
        'advice'  => 'Better if not in a critical partition',
        'vhost'   => 1,
    },
    {
        'name'    => 'archive_default_index',
        'default' => 'thrd',
        'query'   => 'Default index organization when entering the web archive: either threaded (thrd) or in chronological (mail) order',
        'file'    => 'wwsympa.conf',
        'edit'    => '1',
    },
##    {
##        'name'   => 'archived_pidfile',
##        'default' => Sympa::Constants::PIDDIR . '/archived.pid',
##        'query'  => 'File containing archived PID while running.',
##        'file'   => 'wwsympa.conf',
##    },
    {
        'name'  => 'cookie_expire',
        'default' => '0',
        'query' => 'HTTP cookies lifetime',
        'file'  => 'wwsympa.conf',
    },
    {
        'name'  => 'cookie_domain',
        'default' => 'localhost',
        'query' => 'HTTP cookies validity domain',
	'vhost'   => '1',
        'file'  => 'wwsympa.conf',
    },
    {   'name'    => 'cookie_refresh',
        'default' => '60',
        'query' => 'Average interval to refresh HTTP session ID.',
        'file' => 'wwsympa.conf',
    },
    {
        'name'     => 'custom_archiver',
        'optional' => '1',
        'query'    => 'Activates a custom archiver to use instead of MHonArc. The value of this parameter is the absolute path on the file system to the script of the custom archiver.',
        'file'     => 'wwsympa.conf',
        'edit'     => '1',
    },
    {
        'name'   => 'default_home',
        'default' => 'home',
        'query'  => 'Type of main Web page ( lists | home )',
	'vhost'   => '1',
        'file'   => 'wwsympa.conf',
        'edit'   => '1',
    },
    {
        'name'    => 'edit_list',
        'default' => 'owner',
	'file'    => 'sympa.conf',
    },
    {
        'name'    => 'ldap_force_canonical_email',
        'default' => '1',
        'query'  => 'When using LDAP authentication, if the identifier provided by the user was a valid email, if this parameter is set to false, then the provided email will be used to authenticate the user. Otherwise, use of the first email returned by the LDAP server will be used.',
        'file'   => 'wwsympa.conf',
	'vhost' => '1',
    },
    {
        'name'   => 'log_facility',
        'default' => 'LOCAL1',
        'query'  => 'Syslog facility for wwsympa, archived and bounced',
        'file'   => 'wwsympa.conf',
        'edit'   => '1',
        'advice' => 'Default is to use previously defined sympa log facility.',
    },
    {
        'name'    => 'mhonarc',
        'default' => '/usr/bin/mhonarc',
        'query'   => 'Path to MHonArc mail2html plugin',
        'file'    => 'wwsympa.conf',
        'edit'    => '1',
        'advice'  => 'This is required for HTML mail archiving',
    },
    {
        'name'     => 'htmlarea_url',
        'query'    => '',
        'default'  => undef,
        'file'     => 'wwsympa.conf',
	'optional' => 1,
    },
    ##{ one_time_ticket_lifetime: not yet implemented. },
    ##{ one_time_ticket_lockout: not yet implemented. },
    {
        'name'   => 'password_case',
        'default' => 'insensitive',
        'query'  => 'Password case (insensitive | sensitive)',
        'file'   => 'wwsympa.conf',
        'advice' => 'Should not be changed ! May invalid all user password',
        'vhost'  => 1, #FIXME:per-robot config is impossible.
    },
    {
        'name'     => 'review_page_size',
        'query'    => 'Default number of lines of the array displaying users in the review page',
        #'vhost'    => '1', # not yet implemented
        'default'  => 25,
        'file'     => 'wwsympa.conf',
    },
    {
        'name'    => 'title',
        'default' => 'Mailing lists service',
        'query'   => 'Title of main Web page',
	'vhost'   => '1',
        'file'    => 'wwsympa.conf',
        'edit'    => '1',
    },
    ##{ use_html_editor: not yet implemented. },
    ##{ html_editor_url: not yet implemented. },
    ##{ html_editor_init: not yet implemented. },
    ##{ html_editor_hide: not yet implemented. },
    ##{ html_editor_show: not yet implemented. },
    {
        'name'    => 'use_fast_cgi',
        'default' => '1',
        'query'   => 'Is fast_cgi module for Apache (or Roxen) installed (0 | 1)',
        'file'    => 'wwsympa.conf',
        'edit'    => '1',
        'advice'  => 'This module provide much faster web interface',
    },
    {
        'name'     => 'viewlogs_page_size',
        'query'    => 'Default number of lines of the array displaying the log entries in the logs page',
        #'vhost'    => '1', # not yet implemented
        'default'  => 25,
        'file'     => 'wwsympa.conf',
    },
    ##{ your_lists_size: not yet implemented. },
    {
        'name'    => 'http_host',
        'query'   => 'URL of a virtual host',
        'default' => 'http://host.domain.tld',
	'vhost'   => '1',
        'edit'    => '1',
        'file'    => 'sympa.conf',
    },

## Not implemented yet.
##    {
##        'name'    => 'chk_cert_expiration_task',
##        'optional' => '1',
##    },
##    {
##        'name'    => 'crl_update_task',
##        'optional' => '1',
##    },
##    {
##        'name'    => 'ldap_export_connection_timeout',
##        'optional' => '1',
##    },
##    {
##        'name'    => 'ldap_export_dnmanager',
##        'optional' => '1',
##    },
##    {
##        'name'    => 'ldap_export_host',
##        'optional' => '1',
##    },
##    {
##        'name'    => 'ldap_export_name',
##        'optional' => '1',
##    },
##    {
##        'name'    => 'ldap_export_password',
##        'optional' => '1',
##    },
##    {
##        'name'    => 'ldap_export_suffix',
##        'optional' => '1',
##    },
## No longer used
##    {
##        'name'    => 'sort',
##        'default' => 'fr,ca,be,ch,uk,edu,*,com',
##    },
);

