use strict;
use warnings;

use Test::More;

use lib 'lib';

eval "use Test::Pod::Spelling spelling";
isnt($@, undef, 'bad import');

eval {
	use Test::Pod::Spelling (
		spelling => {
			allow_words => [qw[ 
				Goddard LICENCE inline behaviour spelt
				TODO API
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
is( $@, '', 'no errors' );
is( $rv, 2, 'expected spelling errors');

$rv = eval { all_pod_files_spelling_ok()} ;
is( $@, '', 'no errors');
is( $rv, 0, 'no spelling errors in PMs');

$rv = eval { pod_file_spelling_ok( 'lib/Test/Pod/Spelling.pm' ) };
is( $@, '', 'no errors');
is( $rv, 0, 'Test/Pod/Spelling.pm' );


done_testing( 22 );



