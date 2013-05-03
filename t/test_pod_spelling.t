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
		plan tests => 22;
	}
}

eval "use Test::Pod::Spelling spelling";
is( Test::Pod::Spelling->VERSION, '0.4', 'version');

isnt($@, undef, 'bad import');

eval {
	use Test::Pod::Spelling (
		spelling => {
			allow_words => [qw[ 
				Goddard LICENCE inline behaviour spelt
				TODO API inlining
			]]
		},
	);
};

is( $@, '', 'use_ok' );


my $rv = eval { pod_file_spelling_ok( 't/good.pod' ) };
is( $@, '', 'no errors');
is( $rv, 0, 'good.pod' );

$rv = eval { pod_file_spelling_ok( 'lib/Pod/Spelling/Ispell.pm' ) };
is( $@, '', 'no errors');
is( $rv, 0, 'Ispell.pm' );

TODO: {
	local $TODO = 'Intentional error - check_test not working a expected';
	$rv = eval { pod_file_spelling_ok( 't/bad.pod' ) };
}
is( $@, '', 'no fatal errors in bad.pod' );
is( $rv, 2, 'expected spelling errors in bad.pod');

$rv = eval { pod_file_spelling_ok( 'lib/Test/Pod/Spelling.pm' ) };
is( $@, '', 'no errors');
is( $rv, 0, 'Test/Pod/Spelling.pm' ) or BAIL_OUT 'Unexpected';

$rv = eval { all_pod_files_spelling_ok()} ;
is( $@, '', 'no errors');
is( $rv, 0, 'no spelling errors in PMs');


done_testing( );



