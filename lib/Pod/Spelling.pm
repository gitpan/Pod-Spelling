use strict;
use warnings;

package Pod::Spelling;
our $VERSION = 0.1;

use Pod::POM;

use warnings::register;
use Carp;

sub new {
	my ($class, $args) = (
		(ref($_[0])? ref($_[0]) : shift ),
		(ref($_[0])? shift : {@_})
	);

	Pod::POM->default_view( 'Pod::POM::View::TextBasic' )
		or confess $Pod::POM::ERROR;
	
	my $self = bless {
		%$args,
		_parser => Pod::POM->new,
	}, $class;

	# Allow a single word to be allowed:
	if ($self->{allow_words}){
		$self->{allow_words} = [$self->{allow_words}] if not ref $self->{allow_words};
	}		

	if ($self->{not_pod_wordlist}){
		eval { 
			no warnings;
			require Pod::Wordlist 
		};
		warnings::warnif( $@ );
	}
	
	if (ref $self and $self->{import_speller}){
		$self->import_speller( $self->{import_speller} );
	}

	# If no speller was specified and no callback provided,
	# try to find one of the defaults.	
	else {
		if (not $self->{spell_check_callback}){
			foreach my $mod (qw( Ispell Aspell )){
				last if $self->import_speller( 'Pod::Spelling::'.$mod );
			}
		}
		
		$self = $self->_init;
	}

	Carp::croak 'Could not instantiate any spell checker. Do you have Ispell or Aspell installed with dictionaries?'
	if not $self->{spell_check_callback};

	return $self;
}

sub _init { return $_[0] }

sub import_speller {
	my ($self, $class) = @_;

	eval "require $class";	

	if ($@){
		warnings:warnif($@);
		$self->{spell_check_callback} = undef;
		return undef;
	}
	else {
		my $method = $class.'::_init';
		$self = $self->$method;
		$self->{spell_check_callback} = $class."::_spell_check_callback"
			if ref $self;
	}
	
	return ref $self;
}

# Method that accepts one or more lines of text, returns a list mispelt words.
sub _spell_check_callback {
	my $self = shift;
	warnings::warnif( 
		'No spell_check_callback registered: no spell checking is happening!'
	);
	# Return all words as errors
	return split /\s+/, join "\n", @_;	
}


sub _clean_text {
	my ($self, $text) = @_;
	return '' if not $text;
	
	$text =~ s/(\w+::)+\w+/ /gs;	# Remove references to Perl modules
	$text =~ s/[\s]+/ /gs;
	$text =~ s/[\W]+/ /gs;			# Remove punctuation
	
	foreach my $word (  @{$self->{allow_words}} ){
		next if not $word;
		$text =~ s/\b\Q$word\E\b//g;
	}

	unless (exists $self->{no_pod_wordlist}){
		foreach my $word (split /\s+/, $text){
			$word = '' if exists $Pod::Wordlist::Wordlist->{$word};
		}
	}
	
	return $text;
}


# Returns all badly spelt from the file,
# and sets $self->{errors}->[ $line_number-1 ]->[ badly spelt words for this line ]
sub check_file {
	my ($self, $path) = @_;
    my @rv;
    
    $self->{errors} = [];
	
    my $pom = $self->{_parser}->parse_file($path)
    	or confess $self->{_parser}->error();

	my $code = $self->{spell_check_callback};
    
	my $line = 0;
	foreach my $text ( split/[\n\r\f]+/, scalar $pom->content()) {
		$text = $self->_clean_text( $text );
		my @err = $self->$code( $text );
		push @rv, @err;
		$self->{errors}->[$line] = \@err;
		$line ++;
	}
	
	return @rv;
}

sub add_allow_words {
	my $self = shift;
	push @{ $self->{allow_words} }, @_ if $#_;
}


1;

__END__

=head1 NAME

Pod::Spelling - Send POD to a spelling checker

=head1 SYNOPSIS

	use Pod::Spelling;
	my $o = Pod::Spelling->new();
	say 'Spelling errors: ', join ', ', $o->check_file( 'Module.pm' );

	use Pod::Spelling;
	my $o = Pod::Spelling->new( import => 'My::Speller' );
	say 'Spelling errors: ', join ', ', $o->check_file( 'Module.pm' );

	use Pod::Spelling;
	my $o = Pod::Spelling->new(
		allow_words => [qw[ foo bar ]],
	);
	say 'Spelling errors: ', join ', ', $o->check_file( 'Module.pm' );

=head1 DESCRIPTION

This module provides extensible spell-checking of POD.

At present, it requires either Lingua::Ispell and Text::Aspell,
one of which  must be installed on your system, with its binaries, 
unless you plan to use the API to provide your own spell-checker.

=head1 TEXT NOT SPELL-CHECKED

The items below commonly upset spell-checking, though are generally
considered valid in POD, and so are not sent to the spell-checker.

=over 4

=item *

The body of links (C<LE<lt>...E<gt>>) and file-formatted strings (C<FE<lt>...E<gt>>).

=item *

Verbatim blocks (indented text, as used in C<SYNOPSIS> sections.

=item *

Any string containing two colons (C<::>).

=item *

The name of the module as written in the standard POD manner:

	=head1 NAME
	
	Module::Name::Here - brief description here
	
=item *

Words contained in L<Pod::Wordlist|Pod::Wordlist>, though that can be disabled
- see L<Pod::Spelling|Pod::Spelling> for details.

=back
	
=head1 CONSTRUCTOR (new)

Optional parameters:

=over 4

=item C<allow_words>

A list of words to remove from text prior to it being spell-checked.

=item C<no_pod_wordlist>

Prevents the default behaviour of using L<Pod::Wordlist|Pod::Wordlist> 
to ignore words often used in Perl modules, but rarely found in dictionaries.

=item C<import_speller>

Name of a class to that implements
the C<_init> method and the C<Pod::Spelling::_spell_check_callback> method.
Current implementations are L<Pod::Spelling::Ispell|Pod::Spelling::Ispell>
and L<Pod::Spelling::Aspell|Pod::Spelling::Aspell>. If anything else should be
added, please let me know.

=back

If no C<import_speller> is specified, then C<Ispell> is tried, then C<Aspell>,
then the module croaks.

=head1 DEPENDENCIES

L<Pod::POM|Pod::POM>.

=head1 METHODS

=head2 check_file

Accepts a path to a file, runs the spell check, and returns a list of badly-spelt
words, setting the C<errors> field with an array, each entry of which is a list that
represents a line in the file, and thus may be empty if there are no spelling errors.

=head2 add_allow_words

Add a list of words to the 'allow' list specified at constrution.


=head1 ADDING A SPELL-CHECKER

This module is really just a factory class that does nothing but 
provide an API for sending POD to a spelling checker via a callback method,
and returning the results. 

The spell-checking callback method, supplied as a
code reference in the C<spell_check_callback> argument during construction,
receives a list of text, and should return a list of badly-spelt words.

	my $o = Pod::Spelling->new(
		spell_check_callback => sub { 
			my ($self, @text) = @_;
			return $find_bad_words( \@text );
		},
	);

Alternatively, this module can be sub-classed: see the source of
C<Pod::Spelling::Ispell>.

=head1 SEE ALSO

L<Pod::Spelling::Ispell>,
L<Pod::POM>,
L<Pod::POM::View::TextBasic>,
L<Pod::Spell>,
L<Pod::WordList>.

=head1 AUTHOR AND COPYRIGHT

Copyright (C) Lee Goddard, 2011. All Rights Reserved.

Made available under the same terms as Perl.


