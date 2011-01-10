use strict;
use warnings;

use Test::More;
use lib 'lib';

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

		my $o = eval {
			Pod::Spelling->new(  import_speller => $class  );
		};
		
		SKIP: {
			skip $o, 3 if not ref $o;
			isa_ok( $o, 'Pod::Spelling');

			is(
				$o->{spell_check_callback},
				$class.'::_spell_check_callback',
				'callback package for '.$class
			);

			is(
				$o->check_file( 't/good.pod' ),
				1,
				'One expected error'
			);
		}
	}
}

done_testing( 7 );




