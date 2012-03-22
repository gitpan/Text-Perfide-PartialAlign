#!/usr/bin/env perl 
use strict; use warnings;
use Test::More tests => 2;
use Text::Perfide::PartialAlign;

my $l1Hap = {
	wordX  => 1,
	wordY  => 1,

	word1  => 1,
	word2  => 1,
	word3  => 1,
	word4  => 1,
	word5  => 1,
	word6  => 1,
	word7  => 1,
	word8  => 1,
	word9  => 1,
	word10 => 1,
};

my $l2Hap = {
	wordX  => 1,
	wordY  => 1,

	word11 => 1,
	word12 => 1,
	word13 => 1,
	word14 => 1,
	word15 => 1,
	word16 => 1,
	word17 => 1,
	word18 => 1,
	word19 => 1,
};

my $expected_common_hap = {
	wordX => 'wordX',
	wordY => 'wordY',
};

my $got_common_hap = findCommonHap($l1Hap,$l2Hap);
is_deeply($got_common_hap, $expected_common_hap, 'Common Haps without correspondences');

$expected_common_hap = {
	wordX => 'wordX',
	wordY => 'wordY',

	word1 => 'word19',
	word6 => 'word11',
	word7 => 'word12',
	word8 => 'word13',
};
$got_common_hap = findCommonHap($l1Hap,$l2Hap, 't/findCommonHap_corresp.src');
is_deeply($got_common_hap, $expected_common_hap, 'Common Haps with correspondences');

