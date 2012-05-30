#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;
use Text::Perfide::PartialAlign qw/get_corpus/;

my $file = 't/get_corpus.t.src';
my ($corpus,$offsets) = get_corpus($file);

my $expected_corpus = [
	["Even", "the", "clearest", "and", "most", "perfect"],
	["circumstantial", "evidence", "is", "likely", "to", "be"],
	["at", "fault,", "after", "all,", "and", "therefore"],
	["ought", "to", "be", "received", "with", "great"],
	["caution.", "Take", "the", "case", "of", "any", "pencil,"],
	["sharpened", "by", "any", "woman;", "if", "you", "have"],
	["witnesses,", "you", "will", "find", "she", "did", "it"],
	["with", "a", "knife;", "but", "if", "you", "take", "simply"],
	["the", "aspect", "of", "the", "pencil,", "you", "will", "say"],
	["that", "she", "did", "it", "with", "her", "teeth."],
];

my $expected_offsets = [
	[0, 37],
	[38, 80],
	[81, 118],
	[119, 153],
	[154, 194],
	[195, 233],
	[234, 272],
	[273, 312],
	[313, 354],
	[355, 389],
];

is_deeply($corpus, $expected_corpus, "Sentence and word splitting");
is_deeply($offsets,$expected_offsets,"Sentence start and end offsets");
