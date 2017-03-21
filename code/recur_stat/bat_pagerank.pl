#!/usr/bin/perl

my ($f) = @ARGV;

system(qq[python calc_pagerank.py $f]);

system(q[perl -F, -alne '$F[1]=sprintf("%.10f", $F[1]); print "$F[0],$F[1]"' ].qq[$f.pr |sort -t, -k2n,2r > $f.pr.float]);

