#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;

my ($f) = @ARGV;
$f ||= 'test.back.front';

print "read recur\n";
my %recur;
read_table('recursive_dns.txt', 
    skip_head=>1, 
    return_arrayref=>0, 
    sep=>',', 
    conv_sub => sub {
        my ($rr) = @_;
        $recur{$rr->[0]}{user_num} = $rr->[-1];
        $recur{$rr->[0]}{is_important} = $rr->[-1]>50000 ? 1 : 0;
    });

#---------

print "read back\n";
my %final;
read_table($f, 
    return_arrayref=>0, 
    conv_sub => sub {
        my ($rr) = @_;
        my ($back, $front) = @{$rr}[0,1];
        $final{$back}{$front} = 1;
    });

print "write back\n";
open my $fh, '>', 'back_stat.csv';
print $fh "back,front_n,important_front_n,user_num\n";
while(my ($back, $r) = each %final){
    my $front_n = 0;
    my $important_front_n = 0;
    my $user_num = 0;
    for my $f (keys(%$r)){
        $front_n++;
        $important_front_n+=$recur{$f}{is_important} || 0;
        $user_num+=$recur{$f}{user_num} || 0;
    }

    print $fh join(",", $back,
        $front_n, $important_front_n, $user_num,
    ),"\n";
}

#------------

print "read back c\n";
my %final_c;
read_table($f,
    return_arrayref=>0, 
    conv_sub => sub {
        my ($rr) = @_;
        my ($back, $front) = @{$rr}[0,1];
        $back=~s/\.\d+$/.0/;
        $final_c{$back}{$front} = 1;
    });
print "write back c\n";
open my $fh, '>', 'back_c_stat.csv';
print $fh "back,front_n,important_front_n,user_num\n";
while(my ($back, $r) = each %final_c){
    my $front_n = 0;
    my $important_front_n = 0;
    my $user_num = 0;
    for my $f (keys(%$r)){
        $front_n++;
        $important_front_n+=$recur{$f}{is_important} || 0;
        $user_num+=$recur{$f}{user_num} || 0;
    }

    print $fh join(",", $back,
        $front_n, $important_front_n, $user_num,
    ),"\n";
}
