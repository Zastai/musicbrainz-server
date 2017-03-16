package t::MusicBrainz::Server::Controller::WS::2::SearchArtists;

use JSON qw( decode_json encode_json );
use Test::JSON import => [qw( is_valid_json is_json )];
use Test::More;
use Test::Routine;
use Test::XML;

with 't::Mechanize', 't::Context';

my $Test = Test::Builder->new();

# TODO: Move these to some SearchUtils package, for when other SearchXXX.pm tests are added?
sub is_same_json_result($$) {
    my ($got, $expected) = @_;
    # $Test->note("result contents: $got");
    is_valid_json $got, 'well-formed JSON';
    # Drop the 'created' timestamp before comparing contents
    # FIXME: Should the score be ignored too?
    my $json = decode_json($got);
    delete $json->{created} if $json;
    is_json encode_json($json), $expected, 'same contents (ignoring creation timestamp)';
}

sub is_same_xml_result($$) {
    my ($got, $expected) = @_;
    # $Test->note("result contents: $got");
    is_well_formed_xml($got, 'well-formed XML');
    # Drop the 'created' timestamp before comparing contents
    # FIXME: It would probably be better to do this via XML processing (e.g. XSLT)
    # FIXME: Should the score be ignored too?
    $got =~ s/<metadata created="\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z" /<metadata /;
    is_xml($got, $expected, 'same contents (ignoring creation timestamp)');
}

test 'WS/2 Search Request (Artist, Default Search)' => sub {

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;

    my $expected_xml = '<?xml version="1.0" standalone="yes"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#" xmlns:ext="http://musicbrainz.org/ns/ext#-2.0">
  <artist-list count="1" offset="0">
    <artist id="3764e6aa-307f-4d80-86bf-6146488db1ab" type="Group" ext:score="100">
      <name>Voices in the Distance</name>
      <sort-name>Voices in the Distance</sort-name>
      <life-span>
        <ended>false</ended>
      </life-span>
    </artist>
  </artist-list>
</metadata>';

    my $expected_json = {
        count  => 1,
        offset => 0,
        artists => [
            {
                id => '3764e6aa-307f-4d80-86bf-6146488db1ab',
                type => 'Group',
                score => 100,
                name => 'Voices in the Distance',
                'sort-name' => 'Voices in the Distance',
                'life-span' => {
                    ended => JSON::null,
                },
            },
            ],
    };

    $Test->note('XML Format');
    $mech->default_header('Accept' => 'application/xml');
    $mech->get('/ws/2/artist/?query="Voices in the Distance"');
    ok($mech->success, 'request successful');
    is_same_xml_result($mech->content, $expected_xml);

    $Test->note('JSON Format');
    $mech->default_header('Accept' => 'application/json');
    $mech->get('/ws/2/artist/?query="Voices in the Distance"');
    ok($mech->success, 'request successful');
    is_same_json_result($mech->content, encode_json($expected_json));

};

test 'WS/2 Search Request (Artist via MBID)' => sub {

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;

    my $expected_xml = '<?xml version="1.0" standalone="yes"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#" xmlns:ext="http://musicbrainz.org/ns/ext#-2.0">
  <artist-list count="1" offset="0">
    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person" ext:score="100">
      <name>Distance</name>
      <sort-name>Distance</sort-name>
      <country>GB</country>
      <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
        <name>United Kingdom</name>
        <sort-name>United Kingdom</sort-name>
      </area>
      <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
      <life-span>
        <ended>false</ended>
      </life-span>
      <alias-list>
        <alias sort-name="DJ Distance">DJ Distance</alias>
      </alias-list>
      <tag-list>
        <tag count="1">
          <name>dubstep</name>
        </tag>
        <tag count="1">
          <name>uk garage</name>
        </tag>
      </tag-list>
    </artist>
  </artist-list>
</metadata>';

    my $expected_json = {
        count  => 1,
        offset => 0,
        artists => [
            {
                id => '472bc127-8861-45e8-bc9e-31e8dd32de7a',
                type => 'Person',
                score => 100,
                name => 'Distance',
                'sort-name' => 'Distance',
                country => 'GB',
                area => {
                    id          => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                    name        => 'United Kingdom',
                    'sort-name' => 'United Kingdom',
                },
                disambiguation => 'UK dubstep artist Greg Sanders',
                'life-span' => {
                    ended => JSON::null,
                },
                aliases => [
                    {
                        'sort-name'  => 'DJ Distance',
                        name         => 'DJ Distance',
                        locale       => JSON::null,
                        type         => JSON::null,
                        primary      => JSON::null,
                        'begin-date' => JSON::null,
                        'end-date'   => JSON::null,
                    },
                    ],
                tags => [
                    {
                        count => 1,
                        name => 'dubstep',
                    },
                    {
                        count => 1,
                        name => 'uk garage',
                    },
                    ],
            },
            ],
    };

    $Test->note('XML Format');
    $mech->default_header('Accept' => 'application/xml');
    $mech->get('/ws/2/artist/?query=arid:472bc127-8861-45e8-bc9e-31e8dd32de7a&fmt=xml');
    ok($mech->success, 'request successful');
    is_same_xml_result($mech->content, $expected_xml);

    $Test->note('JSON Format');
    $mech->default_header('Accept' => 'application/json');
    $mech->get('/ws/2/artist/?query=arid:472bc127-8861-45e8-bc9e-31e8dd32de7a&fmt=json');
    ok($mech->success, 'request successful');
    is_same_json_result($mech->content, encode_json($expected_json));

};

# TODO: Add a test set for every other search field.
# TODO: Add a test set for a search spanning multiple search fields.
# TODO: Add a test set for paged requests.

1;

