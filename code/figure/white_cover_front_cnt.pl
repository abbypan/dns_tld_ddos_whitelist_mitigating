#!/usr/bin/perl
use SimpleR::Reshape;

my %back;
read_table('white.txt',
    return_arrayref=>0, 
    conv_sub => sub {
        my ($r) =@_;
        $back{$r->[0]}=1;
    });

my %front;
my %all_front;
read_table('recur_front_back.tidy.small.csv',
    return_arrayref=>0, 
    conv_sub => sub {
        my ($r) =@_;
        $all_front{$r->[0]}=1;
        return unless(exists $back{$r->[1]});
        $front{$r->[0]}=1;
    });

my $ok = scalar(keys(%front));
my $all = scalar(keys(%all_front));
my $rate = $ok/$all;
print "$ok, $all, $rate\n";

