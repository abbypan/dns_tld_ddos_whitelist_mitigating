#!/usr/bin/perl

use SimpleR::Reshape;

my $f = 'client_merge_final.learn.csv.libsvm.out.predict.no_small_query.csv';

my $s =0;
my %stat;
read_table($f,
    return_arrayref=>0, 
    conv_sub => sub {
        my ($r) = @_;
        $stat{$r->[0]}{client_cnt}++;
        $stat{$r->[0]}{query_cnt}+=$r->[3];
        $s+=$r->[3];
    });

open my $fh, '>', 'table2.csv';
while(my ($k, $r) = each %stat){
    my $percent = 100*$r->{query_cnt}/$s;
    print $fh "$k,$r->{client_cnt},$r->{query_cnt},$percent\n";
}
close $fh;
