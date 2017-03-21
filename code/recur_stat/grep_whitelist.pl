#!/usr/bin/perl
use SimpleR::Reshape;

my ($f) = @ARGV;

system(q[awk -F, '$2>10 || $4>100000 || $5>2 || $7>300000' ].qq[$f.c.csv.m4.map.csv > $f.c.csv.m4.map.csv.big]);

my %mem;
read_table("$f.c.csv.m4.map.csv.big",
return_arrayref=>0,
conv_sub => sub {
	my ($r) = @_;
	$mem{$r->[0]} = 1 ;
});

read_table("$f.c.n",
		write_file=>"$f.c.n.big",
		return_arrayref=>0,
		conv_sub => sub {
		my ($r) = @_;
		return unless(exists $mem{$r->[3]});
		return $r;
		});

system(q[awk -F, '$5>100000' ].qq[$f.c.n.big > $f.c.n.big.front]);
