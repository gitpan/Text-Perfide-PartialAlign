use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Text::Perfide::PartialAlign',
    license             => 'perl',
    dist_author         => q{Andre Santos <andrefs@cpan.org>},
    dist_version_from   => 'lib/Text/Perfide/PartialAlign.pm',
    build_requires => {
        'Test::More' => 0,
    },
	configure_requires => { 'Module::Build' => 0.38 },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'Text-Perfide-PartialAlign-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
