#!/usr/bin/perl 

use strict;
use warnings;
use SimpleR::Reshape;

my %m ;
read_table('client_cn.csv',
    return_arrayref=>0,
    conv_sub => sub {
        my ($r) = @_;
        $m{$r->[0]}=1;
    }, 
);

read_table('recur_front_back.tidy.log',
    write_file=> 'recur_front_back.tidy.csv',
    conv_sub=>sub {
        my ($r) = @_;
        return unless(exists $m{$r->[0]} or exists $m{$r->[1]});
        return $r;
    }, 
);
