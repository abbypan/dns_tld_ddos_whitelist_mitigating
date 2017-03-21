#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;

#my %recur;
my %recur_c;
my %recur_x;
my %recur_y;

#74.125.41.0

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

    $recur_x{$ip_c} ||= $r->[0];
    if($r->[-1]>5){
	    push @{$recur_y{$ip_c}}, [ $r->[0], $num ] ;
    }
    $recur_x{$ip_c}  = $r->[0] if($num>$recur_c{$ip_c});
    });

my @k = keys(%recur_y);
for my $k (@k) {
	my $r = $recur_y{$k};
	my @sort_y = map { "$_->[0]:$_->[1]" } sort { $b->[1] <=> $a->[1] } @$r;
	my $s = join(";", @sort_y);
	$recur_y{$k} = [ $sort_y[0][1], $s ];
}


my ($f) = @ARGV;
my %rem_back;
read_table($f, 
    write_file=>"$f.map_front",
    return_arrayref=> 0,
    conv_sub => sub {
    my ($r) = @_;
    s/^\s+|\s+$//sg for @$r;

    if(exists $recur_y{$r->[0]}){
	return [ $r->[1], $r->[0], 1, @{$recur_y{$r->[0]}} ];
    }
    	return [ $r->[1], $r->[0], 0, 0, 'unknown' ];
    });

system(qq[sort -t, -k4n,4r $f.map_front > $f.map_front.sort]);
