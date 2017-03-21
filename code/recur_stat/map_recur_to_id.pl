#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;

my $n = 1;
my %recur;

read_table('recur_front_table.csv', 
    return_arrayref=> 0,
    conv_sub => sub {
        my ($r) = @_;
        return if(exists $recur{$r->[0]});
        $recur{$r->[0]} = [ $n, int(10**$r->[-1]) ];
        $n++;
    });

my $f = 'recur_front_back.tidy.csv';
#my $f = 't.csv';
read_table($f, 
    return_arrayref=> 0,
    conv_sub => sub {
        my ($r) = @_;
        if(! exists $recur{$r->[0]}){
            $recur{$r->[0]} = [$n, 1];
            $n++;
        }
        if(! exists $recur{$r->[1]}){
            $recur{$r->[1]} = [$n, 1];
            $n++;
        }
    });

open my $fh, '>', "$f.id.perl";
while(my ($k, $r)= each %recur){
    print $fh "$k,$r->[0],$r->[1]\n";
}
close $fh;

open my $fhw, '>', "$f.graph.perl";
open my $fhr, '<', $f;
while(<$fhr>){
    chomp;
    my ($f, $b) = split /,/;
    print $fhw "$recur{$f}[0],$recur{$b}[0],$recur{$f}[1]\n";
}
close $fhr;
close $fhw;
