## Domain Registry Interface, CZ.NIC Poll EPP extension commands
##
## Copyright (c) 2014-2016 David Makuni <d.makuni@live.co.uk>. All rights reserved.
##
## This file is part of Net::DRI
##
## Net::DRI is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## See the LICENSE file that comes with this distribution for more details.
################################################################################

package Net::DRI::Protocol::EPP::Extensions::CZ::Message;

use Switch;
use strict;
use warnings;
use POSIX qw(strftime);

=pod

=head1 NAME

Net::DRI::Protocol::EPP::Extensions::CZ::Message - .CZ Message extension commands for Net::DRI

=head1 DESCRIPTION

Please see the README file for details.

=head1 SUPPORT

For now, support questions should be sent to:

E<lt>development@sygroup.chE<gt>

Please also see the SUPPORT file in the distribution.

=head1 AUTHOR

David Makuni, E<lt>d.makuni@live.co.ukE<gt>

=head1 COPYRIGHT

Copyright (c) 2014-2016 David Makuni <d.makuni@live.co.uk>. All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

See the LICENSE file that comes with this distribution for more details.

=cut

####################################################################################################

sub register_commands
{
  my ($class, $version) = @_;
  return { 'message' => { 'retrieve' => [ undef, \&parse_poll ] } };
}

####################################################################################################

sub parse_poll {
  my ($po,$otype,$oaction,$oname,$rinfo)=@_;
  my ($keys,$name);

  my $mes=$po->message();
  return unless $mes->is_success();

  my $msgid=$mes->msg_id();
  my $msg_content = $mes->node_msg();

  return unless ((defined($msgid) && $msgid) && (defined($msg_content) && $msg_content));
  $oname = $msgid;

  # finding out what the object type is (if it not defined from above)
  if(ref($mes->ns()) eq 'HASH') {
    foreach my $key (keys(%{$mes->ns()})) {
      my $ns = $mes->ns($key);
      if ($msg_content =~ m/(.+)($ns)(.+)/) {
        $otype = $key if !($otype)
      }
    }
  };

  # check object is defined properly and if not set to 'message'
  $otype = $otype ? $otype : 'message';

  my @res_children = Net::DRI::Util::xml_list_children($msg_content);
  foreach my $el(@res_children) {
    my ($n,$c)=@$el;
    foreach my $el(Net::DRI::Util::xml_list_children($c)) { my ($k,$v)=@$el; if ($k eq 'name') { $oname = $v->textContent(); } }
    _parse_by_type($po,$otype,$oaction,$oname,$rinfo,$n,$c); # process poll
  }

  return;

}

sub _parse_by_type {
  my ($po,$otype,$oaction,$oname,$rinfo,$n,$c)=@_;
  my $generated_action;
  my $msg = {};

  # get all poll information
  if ($n) {
    my @pollData = Net::DRI::Util::xml_list_children($c);
    foreach my $el(@pollData) {
      my ($n,$c)=@$el;
      $rinfo->{$otype}->{$oname}->{$n} = $c->textContent() ? $c->textContent() : '' if ($n);
    }
    my $tmp_name = $rinfo->{$otype}->{$oname}->{name};
    if ($tmp_name) {
      $rinfo->{$otype}->{$oname}->{object_id} = $tmp_name;
    };
    $rinfo->{$otype}->{$oname}->{object_type} = $otype if $otype;
  }


  # From: http://www.nic.cz/files/nic/doc/fred-client-openinstance-2.4.0.zip
  #
  # KEY: elementName - description {objects applicable}
  #
  # trnData - completed transfer {domain/nsset/keyset/contact}
  # idleDelData - deletion of contact because it was not used {nsset/keyset/contact}
  # delData - object was deleted from register {domain}
  # impendingExpData - warning about impending expiration of an object {domain}
  # expData - object has just expired {domain}
  # dnsOutageData - object was outaged from DNS zone {domain}
  # lowCreditData - warning about low credit {fred}
  # requestFeeInfoData - information about requests counts and price {fred}
  # testData - result of technical test {nsset/keyset}
  #
  # This should parse ALL polls for the following objects:
  #
  # 'contact' => 'contact-1.6.1.xsd'
  # 'domain' => 'domain-1.4.xsd'
  # 'fred' => 'fred-1.5.xsd'
  # 'keyset' => 'keyset-1.3.xsd'
  # 'host' => 'host-1.0.xsd'

  # poll type specific changes
  switch ($n) {
    case m/^(?:lowCreditData|requestFeeInfoData)$/ {
      # informative messages not requiring direct action (.e.g running low on credit etc...)
      $generated_action = 'info';
    };
    case m/^(?:trnData)$/ {
      # transfer 'out' of objects domain, contact, nsset or keyset completed
      $generated_action = 'transfer';
    };
    case m/^(?:delData)$/ {
      # objects which have been deleted
      $generated_action = $otype . '-deleted';
    };
    case m/^(?:idleDelData)$/ {
      # data which has been deleted because it was idle
      $generated_action = 'idle-' . $otype . '-deleted';
    };
    case m/^(?:dnsOutageData)$/ {
      # domain was outaged from DNS zone
      $generated_action = 'info';
    };
    case m/^(?:expData)$/ {
      # domain has just expired
      $generated_action = $otype . '-expired';
    };
    case m/^(?:impendingExpData)$/ {
      # domain has just expired
      $generated_action = $otype . '-soon-expire';
    };
    case m/^(?:testData)$/ {
      $generated_action = 'technical-test-result';
    };
  };

  # assign action
  $rinfo->{$otype}->{$oname}->{action} = $generated_action;

  # remove action if object identification failed
  $generated_action = 'unknown' if $otype eq 'message';

  return;

}

1;
