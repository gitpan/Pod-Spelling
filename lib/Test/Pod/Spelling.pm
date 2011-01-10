use strict;
use warnings;

package Test::Pod::Spelling;
our $VERSION = '0.1';

=head1 NAME

Test::Pod::Spelling - A Test library to spell-check POD files

=head1 SYNOPSIS

	use Test::Pod::Spelling;
	all_pod_spelling_ok();
	done_testing();

	use Test::Pod::Spelling (
		spelling => {
				allow_words => [qw[ 
					Goddard LICENCE inline behaviour spelt
				]]
			},
		);
	};
	pod_spelling_ok( 't/good.pod' );
	all_pod_spelling_ok();
	done_testing();
	
=head1 DESCRIPTION

This module exports two routines, described below, to test POD for spelling errors,
using either Lingua::Ispell and Text::Aspell. One of those modules
must be installed on your system, with their binaries, unless you
plan to use the API to provide your own spell-checker.

As illustrated in L</SYNOPSIS>, above, configuration options for C<Pod::Spelling> can
be passed when the module is used.

A list of words that can be allowed even if not in the dictionary 
can be supplied to the spell-checking module when this module is used.
To help keep this list short, common POD that would upset the spell-checker
is skipped - see L<Pod::Spelling/TEXT NOT SPELL-CHECKED> for details.

=cut

use base qw( 
	Test::Builder::Module 
	Exporter 
);

my $CLASS = __PACKAGE__;

=head1 DEPENDENCIES

L<Test::Pod|Test::Pod>,
L<Pod::Spelling|Pod::Spelling>,
L<Test::Builder|Test::Builder>.

=cut

use Test::Builder;
require Test::Pod;
require Pod::Spelling;
use Carp;

my $Test = Test::Builder->new;

=head1 EXPORTS

	all_pod_spelling_ok() 
	pod_spelling_ok() 

=cut

sub import {
    my $self = shift;
    my @args = @_;
    my $spelling_args = {};
    
    # Get the spelling argument:
    for my $i (0..$#args){
    	if ($args[$i] eq 'spelling'){
    		confess 'During import, "spelling" argument must point to a HASH or Pod::Spelling object'
    			if $i==$#args
    			or not ref($args[$i+1]) 
    			or ref($args[$i+1]) !~ /^(HASH|Pod::Spelling.*)$/; 
    		# Use to init obj later
    		$spelling_args = $args[$i+1];
			# Remove from args that will be passed to plan()
    		@args = @args[
				0..$i-1,
				$i+2 .. $#args
			];
    		last;
    	}
    }
    
    $Test->{_speller} = Pod::Spelling->new( $spelling_args );
    
    my $caller = caller;

    for my $func ( qw( all_pod_spelling_ok pod_spelling_ok )) {
        no strict 'refs';
        *{$caller."::".$func} = \&$func;
    }

    $Test->exported_to($caller);
    $Test->plan(@args);
}

=head1 METHODS

=head2 C<all_pod_spelling_ok( [@entries] )>

Exactly the same as L<Test::Pod/all_pod_files_ok( [@entries] )>
except that it calls L<Test::Pod/pod_file_ok( FILENAME[, TESTNAME ] )>
to check the spelling of POD files.

=cut

sub all_pod_spelling_ok {
	my @args = @_ ? @_ : Test::Pod::_starting_points();
    my @paths = map { -d $_ ? Test::Pod::all_pod_files($_) : $_ } @args;
    my @errors;
    
    foreach my $path (@paths){
    	push @errors, pod_spelling_ok( $path );
    }
    
    return keys %{{
    	map {$_=>1} @errors
	}};
}

=head2 C<pod_spelling_ok( FILENAME[, TESTNAME ] )>

Exactly the same as L<Test::Pod/pod_file_ok( FILENAME[, TESTNAME ] )>
except that it checks the spelling of POD files.

=cut

sub pod_spelling_ok {
	my ($path, $name) = @_;
	
	# All good POD has =head1 NAME\n\n$TITLE - $DESCRIPTION
	# so add that title to the dictionary. It may be a script name
	# without colons, so using the module name or path is not enough.
	open my $IN, $path or confess 'Could not open '.$path;
	read $IN, my $file, -s $IN;
	close $IN;
	my ($pod_name) = $file =~ /^=head1\s+NAME[\n\r\f]+\s*(\S+)\s*-\s*/m;
	undef $file;	
	
	if ($pod_name){
		$Test->{_speller}->add_allow_words( $pod_name );
		my $words;
		($words = $pod_name) =~ s/:+/ /g;
		$Test->{_speller}->add_allow_words( 
			split/\s+/, $words
		);
	}
	
	if (not $name){
		$name = 'POD spelling test for '. ( $pod_name || $path );
	}
	
	my @errors = $Test->{_speller}->check_file( $path );

	$Test->ok( not( scalar @errors), $name );

	if (@errors){
		foreach my $line ( 0 .. $#{ $Test->{_speller}->{errors} }){
			my $misspelt = $Test->{_speller}->{errors}->[$line];
			if (scalar @$misspelt){
				$Test->diag( 
					$path . ' (pod line ' . ($line+1) . '): '
					. join ', ', map("\"$_\"", @$misspelt)
				);
			}
		}
	}
	
	return @errors;
}

1;

__END__

=head1 TODO

Automatically skip the name of the author as described in 
F<Makefile.PL> or F<Build.PL> or similar.

=head1 AUTHOR AND COPYRIGHT

Copyright Lee Goddard (C) 2011. All Rights Reserved.

Made available under the same terms as Perl.

