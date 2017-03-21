#!/usr/bin/perl

my ($f) = @ARGV;

my %res;
open my $fh, '<', $f;
while(<$fh>){
    chomp;
    my ($back, $front) = split /,/;
    $front=~s/\.\d+$//;
    $res{$front}{$back}=1; 
}
close $fh;

while(my ($fr, $b) = each %res){
    my $n = keys(%$b);
    $res{$fr} = $n;
}

open my $fh, '>', "$f.front_c.back_cnt.csv";
while(my ($fr, $n) = each %res){
    print $fh "$fr,$n\n";
}
close $fh;
