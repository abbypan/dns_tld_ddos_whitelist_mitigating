#!/usr/bin/perl 

use strict;
use warnings;
use SimpleR::Reshape;

my ($src_f, $out_f, $type_f, $type_colname) = @ARGV;
$type_colname ||= 'predict_type';

my %type;
read_table($type_f, 
    return_arrayref=>0, 
    conv_sub => sub {
        my ($r) = @_;
        $type{$r->[1]} = $r->[0];
});

open my $fhw, '>', "$out_f.predict.csv";
open my $fh, '<', $src_f;
open my $fho, '<', $out_f;
my $head=<$fh>;
chomp($head);
print $fhw "$head,$type_colname\n";
while(<$fh>){
    chomp;
    my $dst_i = <$fho>;
    chomp $dst_i;
    my $type_n = $type{$dst_i};
    print $fhw "$_,$type_n\n";
}
close $fho;
close $fh;
close $fhw;
