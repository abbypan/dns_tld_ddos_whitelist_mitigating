#!/usr/bin/perl

my %big_front;
open my $fh,'<', 'big_front_rec.csv';
while(<$fh>){
chomp;
$big_front{$_} = 1;
}
close $fh;

open my $fh, '<', 'big_back.txt';
open my $fhw, '>', 'big_front_rec_back_front.txt';
while(<$fh>){
chomp;
my ($back, $front) = split /,/;
next if(/Apr/);
next if(/\Q0.0.0.0/);
next unless(exists $big_front{$front});
print $fhw "$_\n";
}
close $fhw;
close $fh;
