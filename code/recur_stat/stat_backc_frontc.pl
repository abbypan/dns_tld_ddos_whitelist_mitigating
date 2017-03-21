#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;

my ($f) = @ARGV;

print "read recur\n";
my %recur;
read_table('recur_front_table.csv', 
    return_arrayref=>0, 
    conv_sub => sub {
        my ($rr) = @_;
	s/^\s+|\s+$// for @$rr;
	my $ip_c = $rr->[0];
	$ip_c=~s/\.\d+$/.0/;
	$recur{$ip_c}{cnt}++;
	my $n = int(10**$rr->[-1]);
	$recur{$ip_c}{important_cnt}++ if($rr->[-1]>5);
	$recur{$ip_c}{important_num}+=$n if($rr->[-1]>5);
	$recur{$ip_c}{num}+= $n;
	$recur{$ip_c}{max_num} ||= 0;
	$recur{$ip_c}{max_num} = $n if($n>$recur{$ip_c}{max_num});
});

#---------
print "read $f\n";
my %final;
read_table($f, 
	return_arrayref=>0, 
	conv_sub => sub {
	my ($rr) = @_;
	my ($b, $f) = @{$rr}[1,0];
	$final{$b}{front_c_cnt}++;
	$final{$b}{front_c_num}+= exists $recur{$f} ? $recur{$f}{num} : 1;
	$final{$b}{important_cnt}+= exists $recur{$f} ? $recur{$f}{important_cnt} : 0;
	$final{$b}{important_num}+= exists $recur{$f} ? $recur{$f}{important_num} : 0;
	$final{$b}{max_front_c_n} ||=1;
	if(exists $recur{$f}){
		my $c = $recur{$f}{max_num};
		$final{$b}{max_front_c_n} = $c if($c>$final{$b}{max_front_c_n});
	}
});

my @head = qw/front_c_cnt front_c_num max_front_c_n important_cnt important_num/;
open my $fh, '>', "$f.front_c.cnt.num.max_n.important.cnt.num";
while(my ($back, $r) = each %final){
print $fh join(",", $back, @{$r}{@head}), "\n";
}
close $fh;
