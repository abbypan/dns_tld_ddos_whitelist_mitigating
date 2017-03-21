#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;
use strict;
use warnings;

my $r = read_table('client_1000_A.csv');
my %dloc = map { my $c = $_->[0]; $c=~s/\.\d+$/.0/; $_->[0]=$c;$c => $_ } @$r;
read_table('360.cn.20150422.csv',
    conv_sub => sub {
        my ($rr) = @_;
        my $b = $rr->[0];
        my $bc =$b;
        $bc=~s/\.\d+$/.0/;
        my $x = $dloc{$bc};
        my $dnssec = $rr->[2]=~/D/ ? 1 : 0;
        return [ @$rr, $dnssec, $x ? 1 : 0 ];
    }, 
    return_arrayref=>0,
    write_file=> '360.cn.client_1000_a.csv', 
);
exit;

### {
#my $r = read_table('bf.big.csv');
my $r = read_table('mr_bf.csv');
my %dloc = map { my $c = $_->[0]; $c=~s/\.\d+$/.0/; $_->[0]=$c;$c => $_ } @$r;
read_table('360.cn.csv',
    conv_sub => sub {
        my ($rr) = @_;
        my $b = $rr->[0];
        my $bc =$b;
        $bc=~s/\.\d+$/.0/;
        my $x = $dloc{$bc};
        my $dnssec = $rr->[2]=~/D/ ? 1 : 0;
        return [ @$rr, $dnssec, $x ? 1 : 0, $x ? @{$dloc{$bc}}[1, 5] : ('', '') ];
    }, 
    return_arrayref=>0,
    write_file=> '360.cn.final.csv', 
);
### }
