use strict;
use warnings;

use ExtUtils::MakeMaker;

my $ok;
my @m = qw( Text::Aspell Lingua::Ispell );

foreach (@m){
	eval "require $_";
	if (not $@){
		$ok = 1;
		last;
	}
}


if (not $ok){
	print "This module requires you have installed on your system
one of either ", join(', ', @m), " Perl modules.\n";
	print <<_STOP_

It appears you have none of these.

If you feel this message to be in error, please contact
the author via LGoddard-at-CPAN-dot-org.

_STOP_
} 

else {
	
	WriteMakefile(
	  ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
	  license( 'perl' ),
	  NAME          => 'Pod::Spelling',
	  AUTHOR        => 'Lee Goddard <lgoddard@cpan.org>',
	  VERSION		=> '0.11',
	  ABSTRACT_FROM => 'lib/Pod/Spelling.pm',
	  PL_FILES      => {},
	  PREREQ_PM     => {
		'Pod::POM'	=> 0.04,
		'Test::Pod' => 0,
		'Test::Builder' => 0,
		'Test::Pod'	=> 0,
	  },
	  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	  clean => { FILES    => 'Pod-Spelling-*' },
	);

}

sub license {
  my $lic = shift;
  local $^W = 0;    # Silence warning about non-numeric version
  return
   unless $ExtUtils::MakeMaker::VERSION >= '6.31';
  return ( LICENSE => $lic );
}



