## Domain Registry Interface, .ASIA EPP extensions
##
## Copyright (c) 2007-2009 Tonnerre Lombard <tonnerre.lombard@sygroup.ch>. All rights reserved.
##           (c) 2010,2013 Patrick Mevzek <netdri@dotandco.com>. All rights reserved.
##
## This file is part of Net::DRI
##
## Net::DRI is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## See the LICENSE file that comes with this distribution for more details.
####################################################################################################

package Net::DRI::Protocol::EPP::Extensions::ASIA;

use strict;
use warnings;

use Net::DRI::Data::Contact::ASIA;
use base qw/Net::DRI::Protocol::EPP/;

=pod

=head1 NAME

Net::DRI::Protocol::EPP::Extensions::ASIA - .ASIA EPP extensions for Net::DRI

=head1 DESCRIPTION

Please see the README file for details.

=head1 SUPPORT

For now, support questions should be sent to:

E<lt>netdri@dotandco.comE<gt>

Please also see the SUPPORT file in the distribution.

=head1 SEE ALSO

E<lt>http://www.dotandco.com/services/software/Net-DRI/E<gt> and
E<lt>http://oss.bsdprojects.net/projects/netdri/E<gt>

=head1 AUTHOR

Tonnerre Lombard E<lt>tonnerre.lombard@sygroup.chE<gt>

=head1 COPYRIGHT

Copyright (c) 2007-2009 Tonnerre Lombard <tonnerre.lombard@sygroup.ch>.
          (c) 2010,2013 Patrick Mevzek <netdri@dotandco.com>
All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

See the LICENSE file that comes with this distribution for more details.

=cut

####################################################################################################

sub setup
{
 my ($self,$rp)=@_;
 $self->ns({ asia => ['urn:afilias:params:xml:ns:asia-1.0','asia-1.0.xsd'],
             ipr  => ['urn:afilias:params:xml:ns:ipr-1.1','ipr-1.1.xsd'],
             oxrs => ['urn:afilias:params:xml:ns:oxrs-1.1','oxrs-1.1.xsd'],
           });
 $self->factories('contact',sub { return Net::DRI::Data::Contact::ASIA->new(@_); });
 $self->capabilities('domain_update','maintainer_url',['set']);
 $self->capabilities('domain_update','contact',['add','set','del']);
 $self->capabilities('domain_update','ipr',['set','del']);
 return;
}

sub default_extensions { return qw/GracePeriod Afilias::IPR ASIA::CED ASIA::Domain SecDNS Afilias::Registrar Afilias::JSONMessage Afilias::IDNLanguage/; }

####################################################################################################
1;
