#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;

#my %recur;
my %recur_c;

read_table('recur_front_table.csv', 
    return_arrayref=> 0,
    conv_sub => sub {
        my ($r) = @_;

        s/^\s+|\s+$//sg for @$r;
	my $ip_c = $r->[0];
	$ip_c=~s/\.\d+$/.0/;
        #return if(exists $recur{$r->[0]});

	my $num = int(10**$r->[-1]) ;
        #$recur{$r->[0]} = $num;

	$recur_c{$ip_c} ||= 0;
	$recur_c{$ip_c}  = $num if($num>$recur_c{$ip_c});
    });

my ($f) = @ARGV;
my %rem_back;
read_table($f, 
    write_file=>"$f.map_0",
    return_arrayref=> 0,
    conv_sub => sub {
        my ($r) = @_;
        s/^\s+|\s+$//sg for @$r;

	if(exists $recur_c{$r->[0]}){
		return [ $r->[0], $r->[1], $recur_c{$r->[0]} ];
	}

	$rem_back{$r->[1]}++;
	return;
    });

open my $fh, '>>', "$f.map_0";
while(my ($back, $n) = each %rem_back){
print $fh "0.0.0.0,$back,$n\n";
}
close $fh;
