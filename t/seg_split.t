#!/usr/bin/env perl 
use strict; use warnings;
use Test::More tests => 4;
use Text::Perfide::PartialAlign;
use Inline::Files;

my $pml = join '', <PML>;


my $expected_corpus =
[
	[ "N\xC3\xA3o", "n\xC3\xA3o", "voc\xC3\xAA", "est\xC3\xA1", "errado",
		"\xC3\x89", "ideia", "minha", "que", "o", "actual", "sabor", "das",
		"ab\xC3\xB3boras", "pode", "ser", "modificado", "Pode-lhes", "ser",
		"-dado", "um", "aroma", ],
	[ "Santo", "Deus", "homem", "isso", "n\xC3\xA3o", "\xC3\xA9", "vinho",
		"clarete", "A", "palavra", "aroma", "recordou", "ao", "Dr", "Burton",
		"o", "copo", "que", "tinha", "no", "bra\xC3\xA7o", "da", "cadeira",
		"Beberricou", "e", "saboreou", ],
	[ "Bom", "vinho", "este", "Muito", "saboroso", "disse", "movendo", "a", 
		"cabe\xC3\xA7a", "aprovativamente", ],
	[ "Mas", "sobre", "o", "neg\xC3\xB3cio", "das", "ab\xC3\xB3boras",
		"voc\xC3\xAA", "n\xC3\xA3o", "fala", "a", "s\xC3\xA9rio",
		"Voc\xC3\xAA", "n\xC3\xA3o", "quer", "dizer", "que", "vai",
		"aviltar-se", "que", "vai", "esgravatar", "a", "terra", "com", "a",
		"forquilha", "estrumar", "aliment\xC3\xA1-la", "com", "fios", "de",
		"algod\xC3\xA3o", "mergulhados", "em", "\xC3\xA1gua", "e", "tudo",
		"o", "mais", ],
	[ "Voc\xC3\xAA", "disse", "Poirot", "parece", "estar", "bem",
		"familiarizado", "com", "a", "cultura", "das", "ab\xC3\xB3boras", ],
];

my $expected_offsets =
[
	[0, 137], 
	[138, 292], 
	[293, 372], 
	[373, 608], 
	[609, 694]
];


my ($got_corpus, $got_offsets) = seg_split(\$pml, { -pml => 1, -punct => 1});

is_deeply($got_corpus, $expected_corpus, 'Segments delimited by <p> </p>.');
is_deeply($got_offsets, $expected_offsets, 'Offsets of segments delimited by <p> </p>.');


$expected_corpus =
[
	["N\xC3\xA3o,", "n\xC3\xA3o,", "voc\xC3\xAA", "est\xC3\xA1", "errado.",
		"\xC3\x89", "ideia", "minha", "que", "o", "actual", "sabor", "das",
		"ab\xC3\xB3boras", "pode", "ser", "modificado.", "Pode-lhes", "ser",
		"-dado", "um", "aroma.", ],
	["Santo", "Deus,", "homem,", "isso", "n\xC3\xA3o", "\xC3\xA9", "vinho",
		"clarete!", "A", "palavra", "aroma", "recordou", "ao", "Dr.",
		"Burton", "o", "copo", "que", "tinha", "no", "bra\xC3\xA7o", "da",
		"cadeira.", "Beberricou", "e", "saboreou.", ],
	["Bom", "vinho,", "este!", "Muito", "saboroso", "disse", "movendo", "a",
		"cabe\xC3\xA7a", "aprovativamente.", ],
	["Mas,", "sobre", "o", "neg\xC3\xB3cio", "das", "ab\xC3\xB3boras",
		"voc\xC3\xAA", "n\xC3\xA3o", "fala", "a", "s\xC3\xA9rio.",
		"Voc\xC3\xAA", "n\xC3\xA3o", "quer", "dizer", "que", "vai",
		"aviltar-se,", "que", "vai", "esgravatar", "a", "terra", "com",
		"a", "forquilha,", "estrumar,", "aliment\xC3\xA1-la", "com", "fios",
		"de", "algod\xC3\xA3o", "mergulhados", "em", "\xC3\xA1gua,", "e",
		"tudo", "o", "mais.", ],
	["Voc\xC3\xAA", "disse", "Poirot", "parece", "estar", "bem",
		"familiarizado", "com", "a", "cultura", "das", "ab\xC3\xB3boras.", ],
];

my $txt = join '', <NEWLINE>;
$expected_offsets = [
	[0, 130], 
	[131, 278], 
	[279, 351], 
	[352, 580], 
	[581, 659]
];

($got_corpus, $got_offsets) = seg_split(\$txt, { -newline => 1, -ws => 1});
is_deeply($got_corpus, $expected_corpus, 'Segments delimited by newline.');
is_deeply($got_offsets, $expected_offsets, 'Offsets of segments delimited by newline.');


__PML__
<p>Não, não, você está errado. É ideia minha que o actual sabor das abóboras pode ser modificado. Pode-lhes ser -dado um aroma.</p>
<p>Santo Deus, homem, isso não é vinho clarete! A palavra aroma recordou ao Dr. Burton o copo que tinha no braço da cadeira. Beberricou e saboreou.</p>
<p>Bom vinho, este! Muito saboroso disse movendo a cabeça aprovativamente.</p>
<p>Mas, sobre o negócio das abóboras você não fala a sério. Você não quer dizer que vai aviltar-se, que vai esgravatar a terra com a forquilha, estrumar, alimentá-la com fios de algodão mergulhados em água, e tudo o mais.</p>
<p>Você disse Poirot parece estar bem familiarizado com a cultura das abóboras.</p>

__NEWLINE__
Não, não, você está errado. É ideia minha que o actual sabor das abóboras pode ser modificado. Pode-lhes ser -dado um aroma.
Santo Deus, homem, isso não é vinho clarete! A palavra aroma recordou ao Dr. Burton o copo que tinha no braço da cadeira. Beberricou e saboreou.
Bom vinho, este! Muito saboroso disse movendo a cabeça aprovativamente.
Mas, sobre o negócio das abóboras você não fala a sério. Você não quer dizer que vai aviltar-se, que vai esgravatar a terra com a forquilha, estrumar, alimentá-la com fios de algodão mergulhados em água, e tudo o mais.
Você disse Poirot parece estar bem familiarizado com a cultura das abóboras.
