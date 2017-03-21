#!/usr/bin/perl
use strict;
use warnings;
use SimpleR::Reshape;
use Data::Dumper;

read_a_log(@ARGV);


sub read_a_log {
    my ($f) = @_;
    my %res;
    read_table($f,
        conv_sub => sub {
            #client,qtype,flag,cnt
            my ($r) = @_;
            my $is_dnssec = $r->[2]=~/D/ ? 1 : 0;
            $res{$r->[0]}[$is_dnssec] ||=0;
            $res{$r->[0]}[$is_dnssec]+=$r->[3] || 0;
        },
        return_arrayref=> 0, 
    );

    open my $fh, '>', "$f.check.csv";
    while(my ($client, $r) = each %res){
        my $client_c = $client;
        $client_c=~s/\.\d+$//;
        $r->[0] ||=0;
        $r->[1] ||=0;
        my $m = $r->[0]+$r->[1];
        print $fh "$client,$client_c,$r->[0],$r->[1],$m\n";
    }
    close $fh;
}


