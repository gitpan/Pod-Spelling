use strict;
use warnings;

use Test::More;

use lib 'lib';

BEGIN {
	eval { require Lingua::Ispell };
	plan skip_all => 'requires Lingua::Ispell' if $@; 
}

BEGIN {
	use_ok('Pod::Spelling');
}

foreach my $pm (qw(
	Lingua::Ispell
	Text::Aspell
)){
	
	my ($mod) = $pm =~ /(\w+)$/;
	my $class = 'Pod::Spelling::'.$mod;
	
	eval "require $class";
	
	SKIP: {
		skip 'Cannot require '.$class, 7 if $@;

		my $o = eval { $class->new };
		
		SKIP: {
			skip "Did not find $class", 6 if not ref $o;
		
			my @r = $o->check_file( 't/good.pod' );
			
			is(  @r, 1, 'Expected errors' );
			is( $r[0], 'Goddard', 'Known unknown word');
			
			$o = $class->new(
				allow_words => 'Goddard'
			);
			isa_ok( $o, $class);
			@r = $o->check_file( 't/good.pod' );
			is(  @r, 0, 'No errors' );
			
			
			$o = $class->new(
				allow_words => ['Goddard'],
			);
			
			isa_ok( $o, $class);
			@r = $o->check_file( 't/good.pod' );
			is(  @r, 0, 'No errors' );
		}
	}
}

done_testing( 13 );

