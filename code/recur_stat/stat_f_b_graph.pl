#!/usr/bin/perl
use SimpleR::Reshape;

my ($f, $i, $j) = @ARGV;

my %rem;
read_table($f, 
    #sep => ' ',
    return_arrayref=>0, 
    conv_sub => sub {
        my ($r) = @_;
        $rem{$r->[$j]} += ( $r->[$i+2] || 1 );
        return;
    }, 
);

read_table($f, 
    write_file => "$f.$i.$j", 
    #sep => ' ',
    return_arrayref=>0, 
    conv_sub => sub {
        my ($r) = @_;
        $r->[$j+2] = ( $rem{$r->[$j]} || 0 );
        return $r;
    }, 
);
