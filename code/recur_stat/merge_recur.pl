#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;

my ($f) = @ARGV;
$f ||= 'client_qrcnt_domcnt.csv';

my %back;
read_table('back_stat.csv', 
    return_arrayref=>0, 
    skip_head=>1, 
    sep=>',', 
    conv_sub => sub {
        my ($rr) = @_;
        $back{$rr->[0]} = $rr;
    });

my %back_c;
read_table('back_c_stat.csv', 
    skip_head=>1, 
    return_arrayref=>0, 
    sep=>',', 
    conv_sub => sub {
        my ($rr) = @_;
        $back_c{$rr->[0]} = $rr;
    });

#---------
read_table('client_qrcnt_domcnt.csv', 
    sep=>',', 
    write_file=> 'client_recur_data.csv', 
    conv_sub => sub {
        my ($rr) = @_;
        my $back_c= $rr->[0];
        $back_c=~s/\.\d+$/.0/;
        my $kk =[ $rr->[0], 
            @{$back{$rr->[0]}}[1,2,3],  
            @{$back_c{$back_c}}[1,2,3],  
        ];
        $_ ||= 0 for @$kk;
 
        return  $kk  });
