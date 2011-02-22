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

