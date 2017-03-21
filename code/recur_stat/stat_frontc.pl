#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;

my ($f) = @ARGV;
$f ||= 'recur_front_back.tidy.csv';

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
	return_arrayref=>0, 
	conv_sub => sub {
	my ($rr) = @_;
	my ($b, $f) = @{$rr}[1,0];
	my $ip_c = $f;
	$ip_c=~s/\.\d+$/.0/;
	
	return if(exists $recur{$ip_c}{ip}{$f});

	$recur{$ip_c}{num}+= 1;
	$recur{$ip_c}{ip}{$f} = 1;
});

open my $fh, '>', "$f.num.cnt.max_n.max_ip.stream";
print $fh "front_c,num,cnt,max_num,max_ip,stream\n";
while(my ($front_c, $r) = each %recur){
	my $n = $r->{num};
	my $rr = $r->{ip};
	my $cnt = keys(%$rr);
	my @d = sort { $b->[1] <=> $a->[1] } map { [ $_ , $rr->{$_} ] } keys(%$rr);
	my $max_n = $d[0][1];
	my $max_ip = $d[0][0];
	my $s = join(";", map { "$_->[0]:$_->[1]" } @d);
	print $fh join(",", $front_c, $n, $cnt, $max_n, $max_ip, $s), "\n";	
}
close $fh;
