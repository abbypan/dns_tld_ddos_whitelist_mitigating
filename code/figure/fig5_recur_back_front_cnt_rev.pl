#!/usr/bin/perl
use SimpleR::Reshape;

my ($f) = @ARGV;

$f ||= 'recur_front_back.tidy.small.csv';

my %stat;
read_table($f, 
		conv_sub => sub {
		my ($r) = @_;
		$stat{$r->[1]}++;
		});

my @dt = sort { $b->[1] <=> $a->[1] } 
map { [ $_, $stat{$_} ] } 
keys(%stat);

open my $fh, '>', 'fig5.csv';
for my $i ( 0 .. $#dt ){
	my $j = $i+1;
	my $d = $dt[$i][1];
	print $fh "$j $d\n";
}
close $fh;
