#============================================================= -*-Perl-*-
#
# Pod::POM::Nodes
#
# DESCRIPTION
#   Module implementing specific nodes in a Pod::POM, subclassed from
#   Pod::POM::Node.
#
# AUTHOR
#   Andy Wardley   <abw@kfs.org>
#
# COPYRIGHT
#   Copyright (C) 2000, 2001 Andy Wardley.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# REVISION
#   $Id: Nodes.pm 76 2009-08-20 20:41:33Z ford $
#
#========================================================================

package SBIA::Pod::POM::Nodes;

require 5.004;
require Exporter;

use strict;

use SBIA::Pod::POM::Node::Pod;
use SBIA::Pod::POM::Node::Head1;
use SBIA::Pod::POM::Node::Head2;
use SBIA::Pod::POM::Node::Head3;
use SBIA::Pod::POM::Node::Head4;
use SBIA::Pod::POM::Node::Over;
use SBIA::Pod::POM::Node::Item;
use SBIA::Pod::POM::Node::Begin;
use SBIA::Pod::POM::Node::For;
use SBIA::Pod::POM::Node::Verbatim;
use SBIA::Pod::POM::Node::Code;
use SBIA::Pod::POM::Node::Text;
use SBIA::Pod::POM::Node::Sequence;
use SBIA::Pod::POM::Node::Content;


use vars qw( $VERSION $DEBUG $ERROR @EXPORT_OK @EXPORT_FAIL );
use base qw( Exporter );

$VERSION = sprintf("%d.%02d", q$Revision: 1.3 $ =~ /(\d+)\.(\d+)/);
$DEBUG   = 0 unless defined $DEBUG;

1;

=head1 NAME

Pod::POM::Nodes - convenience class to load all node classes

=head1 SYNOPSIS

    use Pod::POM::Nodes;

=head1 DESCRIPTION

This module implements a convenience class that simply uses all of the subclasses of Pod::POM::Node.
(It used to include all the individual classes inline, but the node classes have been factored out
into individual modules.)

=head1 AUTHOR

Andy Wardley E<lt>abw@kfs.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2000, 2001 Andy Wardley.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

Consult L<Pod::POM> for a general overview and examples of use.

