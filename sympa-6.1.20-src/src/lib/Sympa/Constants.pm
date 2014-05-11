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

package Sympa::Constants;
use strict;

use Exporter;
our @ISA = qw(Exporter);


use constant VERSION => '6.1.20';
use constant USER    => 'sympa';
use constant GROUP   => 'sympa';

use constant CONFIG           => '/tmp/sympapipo/etc/sympa.conf';
use constant WWSCONFIG        => '/tmp/sympapipo/etc/wwsympa.conf';
use constant SENDMAIL_ALIASES => '/etc/mail/aliases-sympapipo';

use constant PIDDIR     => '/tmp/sympapipo';
use constant EXPLDIR    => '/tmp/sympapipo/list_data';
use constant SPOOLDIR   => '/tmp/sympapipo/spool';
use constant SYSCONFDIR => '/tmp/sympapipo/etc';
use constant LOCALEDIR  => '/tmp/sympapipo/locale';
use constant LIBEXECDIR => '/tmp/sympapipo/bin';
use constant SBINDIR    => '/tmp/sympapipo/bin';
use constant SCRIPTDIR  => '/tmp/sympapipo/bin';
use constant MODULEDIR  => '/tmp/sympapipo/bin';
use constant DEFAULTDIR => '/tmp/sympapipo/default';
use constant STATICDIR  => '/tmp/sympapipo/static_content';
use constant ARCDIR    => '/tmp/sympapipo/arc';
use constant BOUNCEDIR  => '/tmp/sympapipo/bounce';

1;
