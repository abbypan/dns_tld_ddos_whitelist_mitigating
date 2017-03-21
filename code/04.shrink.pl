#!/usr/bin/perl 

use strict;
use warnings;
use SimpleR::Reshape;
use utf8;

my @head = qw/client global_rec_cnt big_rec_cnt q360 qsina qtianya good_cnt_rate log10_sec_dom_cnt log10_qcnt is_china/;

my ($f) = @ARGV;
my $dst_f=$f;
$dst_f=~s/.loc.csv$/.shrink.csv/;

read_table($f, 
    write_file => $dst_f, 
    skip_head => 1, 
    charset=> 'utf8', 
    write_head => \@head, 
    conv_sub => sub {
        my ($r) = @_;
        return [
            $r->[0],
            $r->[3]+$r->[4]+$r->[5]+$r->[6], 
            $r->[11]+$r->[12]+$r->[13]+$r->[14], 
            $r->[17], $r->[20], $r->[23],
            $r->[25], $r->[26], $r->[27],
            ($r->[28] and $r->[28] eq '中国') ? 1 : 0, 
        ];
    },
);

