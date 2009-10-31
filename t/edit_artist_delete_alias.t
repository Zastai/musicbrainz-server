use strict;
use Test::More;
use Test::Moose;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Artist::DeleteAlias' }

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE_ALIAS );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::DeleteAlias');

my ($edits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is(@$edits, 1);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->artist_id, 1);
is($edit->artist->id, 1);
is($edit->artist->edits_pending, 1);
is($edit->alias_id, 1);
is($edit->alias->id, 1);
is($edit->alias->edits_pending, 1);

my $alias_set = $c->model('Artist')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

MusicBrainz::Server::Test::reject_edit($c, $edit);

my $alias_set = $c->model('Artist')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

my $artist = $c->model('Artist')->get_by_id(1);
is($artist->edits_pending, 0);

my $alias = $c->model('Artist')->alias->get_by_id(1);
ok(defined $alias);
is($alias->edits_pending, 0);

my $edit = _create_edit();
MusicBrainz::Server::Test::accept_edit($c, $edit);
$c->model('Edit')->load_all($edit);
is($edit->artist->edits_pending, 0);
ok(!defined $edit->alias);

$alias_set = $c->model('Artist')->alias->find_by_entity_id(1);
is(@$alias_set, 1);

done_testing;

sub _create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_DELETE_ALIAS,
        editor_id => 1,
        entity_id => 1,
        alias_id => 1,
    );
}
