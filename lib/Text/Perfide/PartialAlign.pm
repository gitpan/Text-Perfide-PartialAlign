package Text::Perfide::PartialAlign;

use 5.006;
use strict;
use warnings;
use Data::Dumper;

=head1 NAME

Text::Perfide::PartialAlign - The great new Text::Perfide::PartialAlign!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01_02';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Text::Perfide::PartialAlign;

    my $foo = Text::Perfide::PartialAlign->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=cut

use base 'Exporter';
our @EXPORT = (qw/
	tokenFreq
	hapaxes
	hapaxPositions
	uniqSort
	bagSort
	less
	less_or_equal
	maximalChain
	selectFromChain
	_log
	findCommonHap
	get_corpus
	strInterval
	seg_split
	token_split
	/);

sub _log {
	print STDERR "$_[0]\n";
}

=head2 tokenFreq

Receives an array of lines of a text (each line is an array of words). Calculates the frequency of each word.

=cut

sub tokenFreq {
	my $corpus = shift;
	my $freq = {};
	for my $l (@$corpus) {
		for my $t (@$l) {
			$freq->{$t}++;
		}
	}
	return $freq;
}

=head2 hapaxes

Receives hash token => freq. Returns hash with elements with freq == 1

=cut

sub hapaxes {
	my $freq = shift;
	my $hapaxes = {};
	while(my ($token, $count) = each(%$freq)) {
		$hapaxes->{$token} = 1 if $count == 1;
	}
	return $hapaxes;
}

=head2 hapaxPositions

Builds an hash with term => positions, where position is the number of the sentence in which term occurs.

=cut

sub hapaxPositions {
	my ($hapaxes, $corpus) = @_;
	my $hapaxPos = {};
	my $corpus_size = @$corpus;
	for(my $ind = 0; $ind < $corpus_size; $ind++){
		my $l = $corpus->[$ind];
		for my $t (@$l) {
			$hapaxPos->{$t} = $ind if (defined($hapaxes->{$t}));
		}
	}
	return $hapaxPos;
}

=head2 bagSort

...

=cut

sub bagSort {
	my $l = shift;
	my @sorted;
	my %aux;
	for my $coords (@$l) {
		my ($x,$y) = (@$coords);
		$aux{$x}{$y}++;
	}
	for my $x (sort { $a <=> $b } keys %aux){
		for my $y (sort { $a <=> $b } keys %{$aux{$x}}){
			push @sorted, [$x,$y, $aux{$x}{$y}];
		}
	}
	return \@sorted;
}



=head2 uniqSort

Sorts an array of pairs and removes duplicated pairs.

=cut

sub uniqSort {
	my $l = shift;
	my $hash = {};
	my $uniqSorted = [];
	map { $hash->{$_->[0]}{$_->[1]} = 1 } @$l;
	for my $x (sort { $a <=> $b } keys %$hash){
		for my $y (sort { $a <=> $b } keys %{$hash->{$x}}){
			push @$uniqSorted, [$x,$y];
		}
	}
	return $uniqSorted;
}

=head2 less

Receives two pairs. Checks if both coordinates of the first pair are lower than the second pair.

=cut

sub less {
	my ($a,$b) = @_;
	if ($a->[0] < $b->[0] and $a->[1] < $b->[1])
							{ return 1;	}
	else 					{ return 0; }
}


=head2 less_relaxed

Receives two pairs... 

=cut

sub less_relaxed {
	my ($a,$b) = @_;
	if ($a->[0] == $b->[0] and $a->[1] == $b->[1]){ return 0; }
  	return ($a->[0] <= $b->[0] and $a->[1] <= $b->[1]);
}


=head2 less_or_equal

Receives two pairs. Checks if both coordinates of the first pair are lower or equal than the second pair's.

=cut

sub less_or_equal {
	my ($a,$b) = @_;
	if ($a->[0] <= $b->[0] and $a->[1] <= $b->[1])
							{ return 1;	}
	else 					{ return 0; }
}

=head2 maximalChain

Receives an array of pairs. Using dynamic programming, selects the maximal chain.

=cut

# Assumes that uniqSort was called to the input! (translated from original Hungarian)
sub maximalChain {
	my $pairs = shift;
	# print Dumper @$pairs;
	my $lattice = {};
	for my $p (@$pairs) {
		my $bestLength = 0;
		my $bestPredessor = undef;
		for my $q (@$pairs) {
			if(less_relaxed($q,$p) and defined($lattice->{$q->[0]}{$q->[1]})){
				(my $length,undef) = @{$lattice->{$q->[0]}{$q->[1]}};
				if($bestLength < $length+$q->[2]){
					# print "$bestLength < $length\n";
					$bestLength = $length+$q->[2];
					$bestPredessor = $q;

				}
			}
		}
		$lattice->{$p->[0]}{$p->[1]} = [$bestLength,$bestPredessor];
		#print "$bestLength @$p $bestPredessor\n";
	}
	
	#Compute pair with max bestLength
	my $x = [ map { [$lattice->{$_->[0]}{$_->[1]}[0],$_] } @$pairs ] ;
	my $y = (sort { $b->[0] <=> $a->[0] } @$x)[0];
	my ($bestLength,$p) = @$y;

	my $chain = [];
	while($p){
		push @$chain, $p;
		(my $length, $p) = @{$lattice->{$p->[0]}{$p->[1]}} ;
	}
	return [reverse @$chain ];
}

=head2 findCommonHap

Finds unique terms common to both corpora. Notion of equality can be extended with two lists of correspondences.

=head3 findCommonHap($l1Hap,$l2Hap)

Returns a reference to a hash containing the elements common to the hashes pointed by the references $l1Hap and $l2Hap.

=head3 findCommonHap($l1Hap,$l2Hap,$l1_to_l2,$l2_to_l1)
	
$l1_to_l2 and $l2_to_l1 are references to hashes containing correspondences between words in language1 and language2 and vice-versa.

=cut

sub findCommonHap {
	my ($l1Hap, $l2Hap, $corresp_file) = @_;

	# Original algorithm (find occurences of: unique term_l1 = unique term_l2)
	my %hash;
	@hash{keys %$l1Hap} = keys %$l1Hap;
	my $commonHap = {};
	map { $commonHap->{$_} = $_ }  grep { $hash{$_} } keys %$l2Hap ; 	
	
	# Lists of correspondences
	if (defined($corresp_file)) {
		my $corresp_list = parseCorrespFile($corresp_file);

		foreach my $corresp (@$corresp_list) {
			my ($l1_terms,$l2_terms) = @$corresp;
			my $l1_sum = 0;
			my $l1_term;
			for (@$l1_terms,@$l2_terms){
				if(defined($l1Hap->{$_})){
					$l1_term = $_;
					$l1_sum++;
				}
			}
			next unless $l1_sum == 1;

			my $l2_sum = 0;
			my $l2_term;
			for (@$l2_terms,@$l1_terms){
				if(defined($l2Hap->{$_})){
					$l2_term = $_;
					$l2_sum++;
				}
			}
			next unless $l2_sum == 1;
			$commonHap->{$l1_term} = $l2_term;
		}
	}
	return $commonHap;
}

=head2 selectFromChain

Selects a chain trying to obbey the maximalChunkSize constraint.

=cut

sub selectFromChain {
	my ($chain,$maximalChunkSize) = @_;
	my $forced = 0;
	my $cursor;
	my $filteredChain = [];

	my $chain_size = @$chain;
	for (my $ind = 0; $ind < $chain_size; $ind++) {
		my $p = $chain->[$ind];
		if($ind == 0) {
			push @$filteredChain, $p;
			$cursor = $p;
			next;
		}
		if(	$p->[0] - $cursor->[0] > $maximalChunkSize or
			$p->[1] - $cursor->[1] > $maximalChunkSize) 	{
			my $lastPos;
			$lastPos = ($ind!=0 ? $chain->[$ind-1] : [0,0]);
			if ($lastPos != $cursor)	{ push @$filteredChain, $lastPos }
			else						{
				push @$filteredChain,$p;
				$forced = 1;
			}
			$cursor = $filteredChain->[-1];
		}
	}


	push @$filteredChain, $chain->[-1] unless(defined($filteredChain->[-1]) and
										$filteredChain->[-1]==$chain->[-1]);

	return ($filteredChain,$forced);
}

=head2 get_corpus

Given a file name, splits the segments and words into an array of arrays.

Returns:
 a reference to the array of arrays,
 a reference to an array of pairs with the offsets of the start and end of each segment,
 a reference to the full text

=cut

sub get_corpus {
	my ($filename) = @_;
	open my $fh, '<', $filename or die;
	my ($start,$end);
	$start = 0;
	my $offsets = [];
	my $corpus = [];
	while(<$fh>){
		$end = tell($fh)-1;
		push @$offsets, [$start,$end];
		$start = $end+1;
		push @$corpus, [ split ];
	}
	close $fh;

	open $fh, '<', $filename or die;
	my $txt = join '',<$fh>;
	close $fh;

	return ($corpus, $offsets, \$txt);
}

=head2 strInterval

Given a corpus and a start and end positions, returns a string with the contents within the given range.

=head3 strInterval($corpus,$first,$last)

Concatenates all the words in the lines comprised in the $first..$last-1 range from corpus. 

=head3 strInterval($corpus,$first,$last,$offsets);
	
Retrieves from the original text the substring from the begining of the segment $first to the end of the segment $last;

=cut

sub strInterval {
	my ($corpus,$first,$last,$offsets) = @_;
	unless (defined($offsets)){
		my $s;
		for my $line (@$corpus[$first..$last-1]){
			$s.= (join ' ', @$line) . "\n";
		}
		return $s;
	}
	else {
		my $start = $offsets->[$first][0];
		my $end   = $offsets->[$last-1][1];

		my $txt = $$corpus;
		my $s = substr $txt, $start, ($end-$start+1);
		return $s;
	}
}

=head2 parseCorrespFile

Parses a given file with correspondences between two given languages. File must follow the following DSL:
	file :				correspondence*
	correspondence :	term (',' term)* '=' term (',' term)*
	term :				word (\s word)*

Does not yet support multi-word terms nor multi-term correspondences!

=cut

sub parseCorrespFile {
	my ($filepath) = @_;
	open my $fh, '<', $filepath or die;
	my $corresp_list = [];
	while (<$fh>){
		s/#.*$//;
		next if /^\s*$/;
		chomp;
		my ($str_l1, $str_l2) = split /\s*=\s*/,$_;
		my $terms_l1 = [ split /\s*,\s*/,$str_l1 ];
		my $terms_l2 = [ split /\s*,\s*/,$str_l2 ];
		push @$corresp_list, [$terms_l1,$terms_l2];
	}
	close $fh;

	# open my $debugfh, '>', "$$.corresp" or die;
	# print $debugfh Dumper($corresp_list);
	# close $debugfh;

	return $corresp_list;
}

=head2 seg_split
=cut

sub seg_split {
	my ($txtref, $options) = @_;
	my ($corpus,$offsets);
	($corpus,$offsets) = _seg_split_pml($txtref,$options) if $options->{'-pml'};
	($corpus,$offsets) = _seg_split_newline($txtref,$options) if $options->{'-newline'};
	return ($corpus, $offsets, $txtref);
}

sub _seg_split_pml {
	my ($txtref,$options) = @_;
	my $corpus = [];
	my $offsets = [];

	while($$txtref =~ /<p>(.*?)<\/p>/g){
		my ($start,$end) = ($-[0],$+[0]);
		push @$offsets, [$start,$end];
		push @$corpus, token_split($1,$options);
	}
	return ($corpus, $offsets);
}


sub _seg_split_newline {
	my ($txtref,$options) = @_;
	my $corpus = [];
	my $offsets = [];

	while($$txtref =~ /(.*)\n/g){
		my ($start,$end) = ($-[1],$+[1]);
		push @$offsets, [$start,$end];
		push @$corpus, token_split($1,$options);
	}
	return ($corpus, $offsets);
}

=head2 token_split
=cut

sub token_split {
	my ($seg,$options) = @_;
	my $tokens;
	$tokens = _token_split_ws($seg) if $options->{'-ws'};
	$tokens = _token_split_punct($seg) if $options->{'-punct'};
	return $tokens;
}

sub _token_split_ws {
	my $seg = shift;
	return [ split ' ',$seg ];
}

sub _token_split_punct {
	my $seg = shift;
	return [ split /[\b\s?!\.,]+/, $seg ];
}

=head1 AUTHOR

Andre Santos, C<< <andrefs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-perfide-partialalign at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Perfide-PartialAlign>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Perfide::PartialAlign


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Perfide-PartialAlign>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Perfide-PartialAlign>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Perfide-PartialAlign>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Perfide-PartialAlign/>

=back


=head1 ACKNOWLEDGEMENTS

Based on the original script partialAlign.py bundled with
hunalign -- http://mokk.bme.hu/resources/hunalign/ .

Thanks to Daniel Varga for helping us to understand how partialAlign.py works.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Andre Santos.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Text::Perfide::PartialAlign
