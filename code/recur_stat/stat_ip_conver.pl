#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;

my ($f) = @ARGV;
my %mem;
read_table($f, 
return_arrayref=>0, 
conv_sub => sub {
	my ($r) = @_;
	return unless($r->[6]>0);
	$mem{front}{$r->[0]} = 1;
	$mem{back}{$r->[1]} = $r->[6];
	$mem{front_c}{$r->[2]} = 1;
	$mem{back_c}{$r->[3]} = 1;
});

open my $fh, '>', "$f.qrcnt_0";
print $fh "front ip cnt : ", scalar(keys(%{$mem{front}})), "\n";
print $fh "front ip c cnt : ", scalar(keys(%{$mem{front_c}})), "\n";
print $fh "back ip cnt : ", scalar(keys(%{$mem{back}})), "\n";
print $fh "back ip c cnt : ", scalar(keys(%{$mem{back_c}})), "\n";
my $c = 0;
$c+= $_ for values(%{$mem{back}});
print $fh "back ip qr cnt : ", $c, "\n";
close $fh;
