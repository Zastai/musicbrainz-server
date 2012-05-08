package MusicBrainz::Server::Controller::Role::IPI;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

after 'show' => sub {
    my ($self, $c) = @_;
    my $entity_name = $self->{entity_name};
    my $entity = $c->stash->{ $entity_name };
    $c->model( $self->{model} )->ipi->load_for($entity);
};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut