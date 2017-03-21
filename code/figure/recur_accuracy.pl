#!/usr/bin/perl
use SimpleR::Reshape;

my %back;
my $f = 'recur_front_back.tidy.small.csv';
read_table($f, 
    return_arrayref=>0,
    conv_sub => sub {
        my ($r) = @_;
        $back{$r->[1]}=1;
    });

my %stat;
my $ff = 'client_merge_final.learn.csv.libsvm.out.predict.no_small_query.csv';
read_table($ff,
    return_arrayref=>0,
    conv_sub=>sub {
        my ($r) = @_;
        next unless(exists $back{$r->[2]});
        $stat{$r->[0]}{client_cnt}++;
        $stat{$r->[0]}{query_cnt}+=$r->[3];
    });

open my $fh, '>', 'recur_accuracy.csv';
while(my ($k, $r) = each %stat){
    print $fh "$k,$r->{client_cnt},$r->{query_cnt}\n";
}
close $fh;
