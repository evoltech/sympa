# Fetch.pm - This module includes functions to fetch remote files
#
#<!-- RCS Identication ; $Revision: 5934 $ ; $Date: 2009-07-02 20:43:53 +0200 (jeu. 02 juil. 2009) $ -->
#
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

package WebAgent;

use strict "vars";

use LWP::UserAgent;
## Good documentation : http://articles.mongueurs.net/magazines/linuxmag57.html

our @ISA = qw (LWP::UserAgent);

my ($web_user, $web_passwd);

sub get_basic_credentials {
    my ( $self, $realm, $uri ) = @_;

    return ( $web_user, $web_passwd );
}

sub set_basic_credentials {
    ($web_user, $web_passwd ) = @_;
}

1;
