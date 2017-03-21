#!/usr/bin/perl
use strict;
use warnings;
use SimpleR::Reshape;
use Data::Dumper;
my ($dst, $thr) = @ARGV;

#calc_src_rank($src, "$src.good.$thr.0", 0, $thr); # client => sec_dom_rank
#calc_src_rank("$src.0", "$src.1", 1); # sec_dom => client_rank
#calc_src_rank("$src.1", "$src.0", 0); # client => sec_dom_rank
#calc_src_rank("$src.0", "$src.1", 1); # sec_dom => client_rank
#calc_src_rank("$src.1", "$src.0", 0); # client => sec_dom_rank

our %mem;
calc_client_all_cnt(\%mem, 'client_qcnt.csv');
#calc_client_all_cnt(\%mem, 'a.txt');
#calc_client_good_cnt(\%mem, 'b.txt', 1);
calc_client_good_cnt(\%mem, 'client_secdom_clientqcnt_secdom_srcip_cnt_500.csv', $thr);
open my $fh, '>', $dst;
while(my ($client, $r) = each %mem){
    $r->{good} ||= 0;
    $r->{all} ||=0;
    my $good_rate = ($r->{good} and $r->{all}) ? $r->{good}/$r->{all} : 0;
    print $fh "$client,$r->{all},$r->{good},$good_rate\n";
}
close $fh;

sub calc_client_all_cnt {
    my ($m, $f) = @_;
    read_table(
        $f,
        return_arrayref=>0,
        conv_sub => sub {
            my ($r) = @_;
            $m->{$r->[0]}{all} += $r->[1];
        }
    );
}

sub calc_client_good_cnt {
    my ($m, $f, $good_thr) = @_;
    read_table(
        $f,
        return_arrayref=>0,
        conv_sub => sub {
            my ($r) = @_;
            $m->{$r->[0]}{good} += $r->[2] if($r->[3]>$good_thr);
        }
    );
}


sub calc_src_rank {
    my ($src, $dst, $id, $thr) = @_;
    print "calc_src_rank: $src, $dst, $id\n";

my %c_mem;
read_table($src,
    return_arrayref=>0,
    conv_sub => sub {
        my ($r) = @_;
        $c_mem{$r->[$id]}{cnt}+= $r->[2];
        $c_mem{$r->[$id]}{rank}+= $r->[2] if($r->[3]>$thr);
    },
);

my ($max, $min) = (0, 0);
while(my ($client, $r) = each %c_mem){
    my $n = $r->{rank} / $r->{cnt};
    $c_mem{$client} = $n;
    $max = $n if($n>$max);
    $min = $n if(! $min or $min>$n);
}

#$c_mem{$_} = ($c_mem{$_} - $min)/($max-$min) for keys %c_mem;
read_table($src,
    write_file => $dst, 
    return_arrayref=>0,
    conv_sub => sub {
        my ($r) = @_;
        return [ @{$r}[0,1,2], $c_mem{$r->[$id]} ];
    },
);
}
