#!/usr/bin/perl
use SimpleR::Reshape;

my ($f) = @ARGV;
my $qr_cnt_f = 'client_c_qrcnt.csv';

merge_file( 
    $qr_cnt_f, 
    "$f.front_c.cnt.num.max_n.important.cnt.num", 
    merge_file => "$f.m1", 
    by_x => [ 0 ], 
    value_x => [1], 
    by_y => [ 0 ], 
    value_y => [ 0 .. 5 ], 
);

merge_file( 
    "$f.map_0.pr.float", 
    "$f.m1", 
    merge_file => "$f.m2", 
    by_x => [ 0 ], 
    value_x => [1], 
    by_y => [ 0 ], 
    value_y => [ 0 .. 6 ], 
);

merge_file( 
    "$f.map_c.pr.float", 
    "$f.m2", 
    merge_file => "$f.m3", 
    by_x => [ 0 ], 
    value_x => [1], 
    by_y => [ 0 ], 
    value_y => [ 0 .. 7 ], 
);

system(qq[sort -t, -k7n,7r $f.m3 > $f.m4]);
system(qq[perl -F, -alne 'print "\$F[0],\$F[6]"' $f.m4|sort|uniq > $f.m4_qrcnt]);
system(qq[grep -v unknown $f.m4 > $f.m4_big]);
system(qq[perl -F, -alne 'print "\$F[0],\$F[6]"' $f.m4_big|sort|uniq > $f.m4_big_qrcnt]);

read_table("$f.m4",
 write_head=> [ qw/back_c front_c_cnt front_c_num max_front_num 
		important_front_cnt important_front_num 
		qr_cnt map0_pr mapc_pr qr_cnt_log10/ ],
 write_file => "$f.m4.map.csv", 
 conv_sub => sub {
	my ($r) = @_;
	push @$r, $r->[6]==0 ? 0 : log($r->[6])/log(10);
	return $r;
	});
