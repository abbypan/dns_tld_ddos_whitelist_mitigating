#!/usr/bin/perl
use SimpleR::Reshape;

my ($pre_f, $qcnt_f, $sec_dom_f) = @ARGV;
my $res_f = $pre_f;
$res_f=~s/predict.csv$/final.csv/;

my %see;
read_table($pre_f, 
    conv_sub => sub {
        my ($r) = @_;
        $see{$r->[0]} = $r;
    }, 
    return_arrayref=> 0,
);

open my $fh, '<', $pre_f;
my $head=<$fh>;
chomp($head);
close $fh;

read_table($qcnt_f,
    return_arrayref=>0,
    #write_head=> [ $head, 'qcnt' ], 
    #write_file=> "$res_f.temp",
    conv_sub=> sub {
        my ($r) = @_;
        return unless(exists $see{$r->[0]});
        my $d = $see{$r->[0]};
        push @$d, $r->[1];
        return;
    },
);

read_table($sec_dom_f,
    return_arrayref=>0,
    write_head=> [ $head, 'qcnt', 'secdomcnt' ], 
    write_file=> $res_f,
    conv_sub=> sub {
        my ($r) = @_;
        return unless(exists $see{$r->[0]});
        my $d = $see{$r->[0]};
        push @$d, $r->[2];
        return $d;
    },
);
