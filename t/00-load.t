#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Text::Perfide::PartialAlign' ) || print "Bail out!\n";
}

diag( "Testing Text::Perfide::PartialAlign $Text::Perfide::PartialAlign::VERSION, Perl $], $^X" );
