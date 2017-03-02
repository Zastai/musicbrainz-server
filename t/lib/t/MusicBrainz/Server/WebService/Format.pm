package t::MusicBrainz::Server::WebService::Format;

use JSON qw( decode_json encode_json );
use Test::JSON import => [qw( is_valid_json is_json )];
use Test::More;
use Test::Routine;
use Test::XML;

with 't::Mechanize', 't::Context';

test 'webservice request format handling (XML)' => sub {

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;

    my $Test = Test::Builder->new();

    my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
        <name>Distance</name><sort-name>Distance</sort-name>
        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    </artist>
</metadata>';

    $Test->note('Accept: <blank>');
    $mech->default_header('Accept' => '');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    ok($mech->success, 'request successful');
    is_well_formed_xml($mech->content, 'well-formed XML');
    is_xml($mech->content, $expected, 'expected contents');

    $Test->note('Accept: */*');
    $mech->default_header('Accept' => '*/*');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    ok($mech->success, 'request successful');
    is_well_formed_xml($mech->content, 'well-formed XML');
    is_xml($mech->content, $expected, 'expected contents');

    $Test->note('Accept: application/xml');
    $mech->default_header('Accept' => 'application/xml');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    ok($mech->success, 'request successful');
    is_well_formed_xml($mech->content, 'well-formed XML');
    is_xml($mech->content, $expected, 'expected contents');

    $Test->note('fmt=xml');
    $mech->default_header('Accept' => 'application/something-else');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?fmt=xml');
    ok($mech->success, 'request successful');
    is_well_formed_xml($mech->content, 'well-formed XML');
    is_xml($mech->content, $expected, 'expected contents');

};

test 'webservice request format handling (JSON)' => sub {

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;

    my $Test = Test::Builder->new();

    my $expected = {
        id => '472bc127-8861-45e8-bc9e-31e8dd32de7a',
        name => 'Distance',
        'sort-name' => 'Distance',
        country => JSON::null,
        area => JSON::null,
        begin_area => JSON::null,
        end_area => JSON::null,
        disambiguation => 'UK dubstep artist Greg Sanders',
        'life-span' => {
            begin => JSON::null,
            end => JSON::null,
            ended => JSON::false,
        },
        type => 'Person',
        'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
        ipis => [],
        isnis => [],
        gender => JSON::null,
        'gender-id' => JSON::null,
    };

    $Test->note('Accept: application/json');
    $mech->default_header('Accept' => 'application/json');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    ok($mech->success, 'request successful');
    is_valid_json($mech->content, 'well-formed JSON');
    is_json($mech->content, encode_json($expected), 'expected contents');

    $Test->note('fmt=json');
    $mech->default_header('Accept' => 'application/something-else');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?fmt=json');
    ok($mech->success, 'request successful');
    is_valid_json($mech->content, 'well-formed JSON');
    is_json($mech->content, encode_json($expected), 'expected contents');

};

test 'webservice request format handling (errors)' => sub {

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;

    my $Test = Test::Builder->new();

    my $expected = '<?xml version="1.0"?>
<error>
  <text>Invalid format. Either set an Accept header (recognized mime types are application/json and application/xml), or include a fmt= argument in the query string (valid values for fmt are json and xml).</text>
  <text>For usage, please see: http://musicbrainz.org/development/mmd</text>
</error>';

    $Test->note('Accept: application/something-else');
    $mech->default_header('Accept' => 'application/something-else');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a');
    is($mech->status, 406, 'server reports 406 - Not Acceptable');
    is_well_formed_xml($mech->content, 'well-formed XML');
    is_xml($mech->content, $expected, 'expected contents');

    $Test->note('fmt=unicorn');
    $mech->default_header('Accept' => 'application/json');
    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?fmt=unicorn');
    is($mech->status, 406, 'server reports 406 - Not Acceptable');
    is_well_formed_xml($mech->content, 'well-formed XML');
    is_xml($mech->content, $expected, 'expected contents');

};

1;
