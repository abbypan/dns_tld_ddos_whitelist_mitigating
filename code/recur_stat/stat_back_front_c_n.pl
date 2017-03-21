#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;

my ($f) = @ARGV;
$f ||= 'recur_front_back.tidy.csv';

my %client_qrcnt_domcnt;
read_table('client_qrcnt_domcnt.csv',
return_arrayref=>0,
conv_sub => sub {
	my ($r) = @_;
	$client_qrcnt_domcnt{$r->[0]} = [ $r->[1], $r->[2] ];
});

print "read recur\n";
my %recur;
read_table('recur_front_table.csv', 
    return_arrayref=>0, 
    conv_sub => sub {
        my ($rr) = @_;
	s/^\s+|\s+$// for @$rr;
	my $ip_c = $rr->[0];
	$ip_c=~s/\.\d+$/.0/;

	$recur{$ip_c}{$rr->[0]} = 1;

	my $n = int(10**$rr->[-1]);
	$recur{$ip_c}{num}+= $n;
	
	$recur{$ip_c}{ip}{$rr->[0]} = $n;
});

#---------
print "read $f\n";
read_table($f, 
	write_file => "$f.c.n",
	return_arrayref=>0, 
	conv_sub => sub {
	my ($rr) = @_;
	s/^\s+|\s+$// for @$rr;

	my ($b, $f) = @{$rr}[1,0];

	my $f_c = $f;
	$f_c=~s/\.\d+$/.0/;

	my $b_c = $b;
	$b_c=~s/\.\d+$/.0/;
	
	return [ $f, $b, $f_c, $b_c, 
	$recur{$f_c}{num} || 1, $recur{$f_c}{ip}{$f} || 1, 
	$client_qrcnt_domcnt{$b}[0] || 0, $client_qrcnt_domcnt{$b}[1] || 0, 
	 ];
});

