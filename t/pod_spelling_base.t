use strict;
use warnings;

use Test::More;
use lib 'lib';

BEGIN {
	use_ok('Pod::Spelling');
}

no warnings 'Pod::Spelling';

my $o = Pod::Spelling->new;

isa_ok( $o, 'Pod::Spelling');

ok( $o->check_file( 't/good.pod' ), 'default dummy callback');


$o = Pod::Spelling->new(
	use_pod_wordlist => 1,
);

isa_ok( $o, 'Pod::Spelling');

is( 
	$o->check_file( 't/pod_wordlist.pod' ), 
	0,
	'even default dummy callback passes pod-wordlist'
);


$o = Pod::Spelling->new(
	allow_words => 'Goddard',
);

isa_ok( $o, 'Pod::Spelling');

unlike( 
	join('', $o->check_file( 't/good.pod' )), 
	qr/Goddard/,
	'even default dummy callback passes allow_word'
);

done_testing( 7 );




