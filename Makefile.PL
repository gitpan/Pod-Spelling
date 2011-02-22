use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
  license( 'perl' ),
  NAME          => 'Pod::Spelling',
  AUTHOR        => 'Lee Goddard <lgoddard@cpan.org>',
  VERSION		=> '0.6',
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

sub license {
  my $lic = shift;
  local $^W = 0;    # Silence warning about non-numeric version
  return
   unless $ExtUtils::MakeMaker::VERSION >= '6.31';
  return ( LICENSE => $lic );
}


