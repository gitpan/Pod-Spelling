use strict;
use warnings;

use Test::More;

BEGIN {
	use lib 'lib';
	use_ok('Pod::Spelling');
}

my $o = Pod::Spelling->new(
	spell_check_callback => sub { return 'foo' },
);

isa_ok( $o, 'Pod::Spelling');

like( 
	join('',$o->check_file( 't/good.pod' )),
	qr/^(foo)+$/,
	'override callback'
);

done_testing( 3 );

