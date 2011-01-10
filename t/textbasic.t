use strict;
use warnings;

use Test::More;
use Pod::POM;

BEGIN {
	use lib 'lib';
	use_ok('Pod::POM::View::TextBasic');
}

Pod::POM->default_view( 'Pod::POM::View::TextBasic' )
	or fail $Pod::POM::ERROR;

my $p = Pod::POM->new( warn => 1 );

isa_ok(
	$p,
	'Pod::POM'
);
	
my $pom = $p->parse_file( 't/good.pod' )
	or fail $p->error();

ok( $pom->content, 'got content');

done_testing();

