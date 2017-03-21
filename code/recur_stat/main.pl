#!/usr/bin/perl

my ($f) = @ARGV;

system(q[ perl -F, -alne 's/\.\d+$/.0/ for @F; print "$F[0],$F[1]"' ].qq[ $f |sort |uniq > $f.c.csv ]);

system(qq[perl map_tidy_0.pl $f.c.csv]);
system(qq[python calc_pagerank.py $f.c.csv.map_0]);
system(q[perl -F, -alne '$F[1]=sprintf("%.10f", $F[1]); print "$F[0],$F[1]"' ].qq[$f.c.csv.map_0.pr |sort -t, -k2n,2r > $f.c.csv.map_0.pr.float]);

system(qq[perl map_tidy_c.pl $f.c.csv]);
system(qq[python calc_pagerank.py $f.c.csv.map_c]);
system(q[perl -F, -alne '$F[1]=sprintf("%.10f", $F[1]); print "$F[0],$F[1]"' ].qq[$f.c.csv.map_c.pr |sort -t, -k2n,2r > $f.c.csv.map_c.pr.float]);

system(qq[perl stat_backc_frontc.pl $f.c.csv]);

system(qq[perl center_merge.pl $f.c.csv]);

system(qq[perl stat_back_front_c_n.pl $f]);
system(qq[perl stat_frontc.pl $f]);

system(qq[perl grep_whitelist.pl $f]);

system(qq[perl stat_ip_conver.pl $f.c.n]);
system(qq[perl stat_ip_conver.pl $f.c.n.big]);
