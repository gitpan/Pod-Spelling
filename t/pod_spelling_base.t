use strict;
use warnings;

use Test::More;
use lib 'lib';

BEGIN {
	my $no_pm;
	eval { require Lingua::Ispell };
	if ($@){
		eval { 
			require Text::Aspell;
			my $o = Text::Aspell->new;
			$o->check('house');
			die $o->errstr if $o->errstr;
		};
	}
	if ($@){
		plan skip_all => 'requires Lingua::Ispell or Text::Aspell' ; 
		$no_pm ++;
	}
	if (!$no_pm) {
		plan tests => 21;
	}
}

BEGIN {
	use_ok('Pod::Spelling');
}


no warnings 'Pod::Spelling';

my $o = eval { Pod::Spelling->new };

isa_ok( $o, 'Pod::Spelling') or BAIL_OUT "";

ok( $o->check_file( 't/good.pod' ), 'default dummy callback');

$o = Pod::Spelling->new( use_pod_wordlist => 1, );

isa_ok( $o, 'Pod::Spelling');

is( 
	$o->check_file( 't/pod_wordlist.pod' ), 
	0,
	'even default dummy callback passes pod-wordlist'
);

$o = Pod::Spelling->new( allow_words => 'Goddard', );
isa_ok( $o, 'Pod::Spelling');

unlike( 
	join('', $o->check_file( 't/good.pod' )), 
	qr/Goddard/,
	'even default dummy callback passes allow_word'
);

done_testing();




