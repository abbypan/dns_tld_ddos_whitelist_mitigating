#!/usr/bin/perl

my ($f) = @ARGV;

my %res;
open my $fh, '<', $f;
while(<$fh>){
    chomp;
    my ($back, $front) = split /,/;
    $back=~s/\.\d+$//;
    $res{$back}{$front}=1; 
}
close $fh;

while(my ($b, $f) = each %res){
    my $n = keys(%$f);
    $res{$b} = $n;
}

open my $fh, '>', "$f.back_c.front_cnt.csv";
while(my ($b, $n) = each %res){
    print $fh "$b,$n\n";
}
close $fh;
